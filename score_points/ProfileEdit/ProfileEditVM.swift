

import UIKit
import RxSwift
import RxCocoa
import Contacts



extension ProfileModule.Edit {
  class ViewModel: BaseViewModel {
    private let isLoading = PublishSubject<Bool>()
    var loading : Driver<Bool>
    var errorOccured : Driver<String>!

    let redoUser: BehaviorRelay<UserData>
    let tableElems: Observable<[ProfileEditCellModel]>
    let tableElemsSubj = ReplaySubject<[ProfileEditCellModel]>.create(bufferSize: 1)
    let initialIsMale: Bool
    let bioText:String
    let initialIsTeam: Bool
    let isSelfScoringVisible = PublishSubject<Bool>()

    let router: ProfileModule.Router
    let deps: Dependencies

    var statisticData = PublishSubject<(Int, Double)>()

    fileprivate let showAllInfo = PublishSubject<Bool>()
    fileprivate let surname = PublishSubject<String>()
    fileprivate let name = PublishSubject<String>()
    fileprivate let city = PublishSubject<String>()
    fileprivate let region = PublishSubject<String>()
    fileprivate let street = PublishSubject<String>()
    fileprivate let zipCode = PublishSubject<String>()
    fileprivate let houseNumber = PublishSubject<String>()
    fileprivate let middleName = PublishSubject<String>()
    fileprivate let mobilePhone = PublishSubject<String>()
    fileprivate let homePhone = PublishSubject<String>()
    fileprivate let country = PublishSubject<Country>()

    fileprivate let countryInited = PublishSubject<Void>()
    fileprivate let phoneInited = PublishSubject<Void>()
    

    init(router: ProfileModule.Router, deps: Dependencies) {
      self.deps = deps
      self.router = router
      guard let user = deps.profileService.profile else {
        fatalError()
      }
      self.redoUser = BehaviorRelay<UserData>(value: user)
      initialIsMale = user.isMale()
      bioText = user.bio
      initialIsTeam = user.employment_type == 1
      tableElems = tableElemsSubj.asObservable()
      loading = isLoading.asDriverOnErrorJustComplete()
    }
  }
}

// MARK: - all dependencies
extension ProfileModule.Edit.ViewModel {
  struct Bindings {
    let save: Driver<Void>
    let isMale: Driver<Bool>
    let isTeamMember: Driver<Bool>
    let bio: Driver<String>
    let modelDeleted: Driver<ProfileEditCellModel>
    let image: Driver<UIImage>
    let selected: Driver<ProfileEditCellModel>
    let close:Driver<Void>
  }
  
  struct Dependencies {
    let profileService: ProfileService
    let countryService: CountryService
    let imgLoadService: ImageLoadService
    let statisticService: StatisticService
    let scoreService: ScoreService
  }
}

// MARK: - input
extension ProfileModule.Edit.ViewModel {
  func configure(with bindings: Bindings) {
    let errorTracker = ErrorTracker()
    let activityTracker = ActivityIndicator()
    
    loading = activityTracker.asDriver()
    
    errorOccured = errorTracker
        .filter({
            if case APIError.stateError = $0 {
                return false
            }
            return true
        })
        .asDriver()
        .map({ $0.localizedDescription })

    prepareCells()
    
    /*
    bindings.seeStory.asObservable().bind { [unowned self] _ in
      self.router.seeStatistic()
    }.disposed(by: disposeBag) */

    let isAvailableSelfScoring = redoUser.asObservable()
      .first()
      .flatMap { [weak self] ud -> Single<(pro: Bool, social: Bool)> in
        guard let user = ud,
          let self = self
          else { return Single.just((pro: false, social: false)) }
        return self
          .deps
          .scoreService
          .isSelfScoredPassed(makesBy: user.userId)
          .map { return (pro: !$0.pro, social: !$0.social) }
          .asObservable()
          .share()
          .trackError(errorTracker)
          .catchErrorJustReturn((pro: false, social: false))
          .asSingle()
      }
      .asObservable()

    isAvailableSelfScoring.map { isAvailable in
      if !isAvailable.pro && !isAvailable.social { return false }
      return true
    }
    .bind(to: isSelfScoringVisible)
    .disposed(by: disposeBag)

    let scoreUselfData = Observable
      .combineLatest(
        redoUser.asObservable(),
        isAvailableSelfScoring.asObservable()
    )
    

    
    
    phoneInited.asObservable().bind { [unowned self] _ in
      self.router.openChangePhoneNumber()
    }.disposed(by: disposeBag)


    countryInited.asObservable().bind { [unowned self] _ in
      
        
        
        self.router.openCountrySelect(observer: self.country.asObserver())
    }.disposed(by: disposeBag)

    
    bindings
        .close
        .asObservable()
        .bind { [weak self] _ in
            self?.router.back()
            //self?.router.back_to_profile()
        }.disposed(by: disposeBag)
    
    bindings
      .isMale
      .asObservable()
      .bind { [unowned self] isMale in
        let currentProfile = self.redoUser.value
        currentProfile.gender = isMale ? 1 : 0 // "1" : "0"
        self.redoUser.accept(currentProfile)
      }
      .disposed(by: disposeBag)

    bindings
      .isTeamMember
      .asObservable()
      .bind { [unowned self] isTeamMember in
        let currentProfile = self.redoUser.value
        currentProfile.employment_type = isTeamMember ? 1 : 0
        self.redoUser.accept(currentProfile)
      }
      .disposed(by: disposeBag)

    bindings
      .bio
      .asObservable()
      .bind { [unowned self] bio in
        let currentProfile = self.redoUser.value
        currentProfile.bio = bio
        self.redoUser.accept(currentProfile)
      }
      .disposed(by: disposeBag)

    surname
      .asObservable()
      .bind { [unowned self] surname in
        let currentProfile = self.redoUser.value
        currentProfile.lastName = surname
        self.redoUser.accept(currentProfile)
      }
      .disposed(by: disposeBag)
    
    
    
    name
      .asObservable()
      .bind { [unowned self] name in
        let currentProfile = self.redoUser.value
        currentProfile.firstName = name
        self.redoUser.accept(currentProfile)
      }
      .disposed(by: disposeBag)

    middleName
      .asObservable()
      .bind { [unowned self] name in
        let currentProfile = self.redoUser.value
        currentProfile.middleName = name
        self.redoUser.accept(currentProfile)
      }
      .disposed(by: disposeBag)

    city
      .asObservable()
      .bind { [unowned self] city in
        let currentProfile = self.redoUser.value
        currentProfile.town = city
        self.redoUser.accept(currentProfile)
      }
      .disposed(by: disposeBag)

    region
      .asObservable()
      .bind { [unowned self] region in
        let currentProfile = self.redoUser.value
        currentProfile.region = region
        self.redoUser.accept(currentProfile)
      }
      .disposed(by: disposeBag)

    street
      .asObservable()
      .bind { [unowned self] street in
        let currentProfile = self.redoUser.value
        currentProfile.street = street
        self.redoUser.accept(currentProfile)
      }
      .disposed(by: disposeBag)

    zipCode
      .asObservable()
      .bind { [unowned self] zip in
        let currentProfile = self.redoUser.value
        currentProfile.zip = zip
        self.redoUser.accept(currentProfile)
      }
      .disposed(by: disposeBag)

    houseNumber
      .asObservable()
      .bind { [unowned self] num in
        let currentProfile = self.redoUser.value
        currentProfile.building = num
        self.redoUser.accept(currentProfile)
      }
      .disposed(by: disposeBag)

    homePhone
      .asObservable()
      .bind { [unowned self] phone in
        let currentProfile = self.redoUser.value
        currentProfile.homePhone = phone
        self.redoUser.accept(currentProfile)
      }
      .disposed(by: disposeBag)

    country
      .asObservable()
      .bind { [unowned self] country in
        let currentProfile = self.redoUser.value
        currentProfile.country = country.id
        self.redoUser.accept(currentProfile)
      }
      .disposed(by: disposeBag)

    bindings
      .modelDeleted
      .asObservable()
      .observeOn(MainScheduler.instance)
      .bind { [unowned self] model in
        
        
        guard let id = model.hideIdentifier else { return }
        
        
        let currentProfile = self.redoUser.value

        if currentProfile.hiddenFields.contains(id) {
          currentProfile.hiddenFields.removeAll { $0 == id }
        } else {
          currentProfile.hiddenFields.append(id)
        }
        self.redoUser.accept(currentProfile)

        self.prepareCells()
      }
      .disposed(by: disposeBag)

    bindings
      .save
      .asObservable()
      .withLatestFrom(redoUser)
      .bind { [unowned self] user in
        self.deps.profileService.update(by: user.toUpdatedParams())
        self.router.back()
        //self.router.closeTop()
      }
      .disposed(by: disposeBag)
    
    /*
    bindings
        .selected
        .asObservable()
        .bind { [weak self] model_ in
            if model_.header == "Mobile Number" {
                self?.router.openChangePhoneNumber()
            }
        }.disposed(by: disposeBag) */
    
    bindings
      .image
      .asObservable()
      .map { [weak self] image -> UIImage in
        self?.isLoading.onNext(true)
        
        return image
      }
      .flatMapLatest { [unowned self] image -> Observable<String> in
        
        
        
       
        
        
        
        return self
            .deps
            .imgLoadService
            .load(avatar: image)
            .share()
            .trackError(errorTracker)
            .catchErrorJustReturn("")
            .trackActivity(activityTracker)
      }

      .bind { [unowned self] image in
        
        self.isLoading.onNext(false)
        let currentProfile = self.redoUser.value
        currentProfile.selfie = image
        
        self.redoUser.accept(currentProfile)
      }
      .disposed(by: disposeBag)

    //guard let usr = deps.profileService.profile else { return }
    //let rating = usr.rating()
    
    self.deps
        .scoreService
        .observeRates(ofMe: self.deps.profileService.profile!.userId)
        .asObservable()
        .share()
        .flatMapLatest { data -> Observable<([StatisticElem],[Rate])> in
            return  self.deps
                   .scoreService
                   .get_rate_statistics()
                   .asObservable()
                   .map {
                        return ($0, data)
                   }
                
        }.bind { [weak self] data in
            
            let rates_are = data.1
            var statictis_rates = data.0
            print("statictics is \(statictis_rates)")
            let ratedIds = rates_are.map { $0.value }
            let rate_ids = ratedIds.reduce(0,+) / Double(ratedIds.count)

            statictis_rates = statictis_rates.sorted {
                return $0.value < $1.value
            }
            var percent:Int = 0
            for (index,rating_) in statictis_rates.enumerated() {
                if index == statictis_rates.count - 1 {
                    if rate_ids >= rating_.value {
                        percent = rating_.percent
                    }
                } else {
                    let next = statictis_rates[index + 1]
                    if rate_ids > rating_.value && rate_ids <= next.value {
                        percent = rating_.percent
                    } else if rate_ids == rating_.value {
                        percent = rating_.percent
                    }
                }
            }
            self?.statisticData.onNext((percent, rate_ids))
        }.disposed(by: disposeBag)
    


  }
    

  func prepareCells() {
    let initialProfile = self.redoUser.value

    var models = [ProfileEditCellModel]()


    let name = TextfieldEditCellModel(
      placeholder: "First Name", //L10n.Profile.Edit.name,
      header: "First Name",//L10n.Profile.Edit.name,
      isShowing: !initialProfile.hiddenFields.contains("firstName"),
      hideIdentifier: "firstName",
      initialValue: initialProfile.firstName,
      output: self.name.asObserver(), max_count: nil
    )

    
    
    let middleName = TextfieldEditCellModel(
      placeholder: "Last Name",//L10n.Profile.Edit.middleName,
      header: "Last Name",//L10n.Profile.Edit.middleName,
      isShowing: !initialProfile.hiddenFields.contains("middleName"),
      hideIdentifier: "middleName",
      initialValue: initialProfile.lastName,
      output: self.middleName.asObserver(), max_count: nil
    )

    


    let countryObservable = redoUser
      .map { user -> String in user.country ?? "" }
      .map { [weak self] id -> String in
        if id.isEmpty { return  "Not selected" /*L10n.Profile.Edit.notSelected*/ }
        return self?.deps.countryService.get(with: id) ?? "Not selected" //L10n.Profile.Edit.notSelected
      }

    let countryStr: String
    if let initialCountryId = initialProfile.country,
      !initialCountryId.isEmpty,
      let countryName = deps.countryService.get(with: initialCountryId),
      !countryName.isEmpty {
      countryStr = countryName
    } else {
      countryStr = "Not selected"//L10n.Profile.Edit.notSelected
    }

    let country = SelectEditCellModel(
      header: "Residence Country", //L10n.Profile.Edit.country,
      initialValue: countryStr,
      isShowing: !initialProfile.hiddenFields.contains("country"),
      hideIdentifier: "country",
      input: countryObservable.asObservable(),
      output: self.countryInited.asObserver()
    )


    
    
    let mobilePhone = SelectEditCellModel(
      header: "Mobile Number", //L10n.Profile.Edit.country,
      initialValue: countryStr,
      isShowing: !initialProfile.hiddenFields.contains("phone"),
      hideIdentifier: "phone",
      input: Observable<String>.just(initialProfile.phone),
      output: self.phoneInited.asObserver()
    )
    
    
    models.append(mobilePhone)
    models.append(name)
    //models.append(surname)
    models.append(middleName)
    models.append(country)



    tableElemsSubj.onNext(models)
  }
}
