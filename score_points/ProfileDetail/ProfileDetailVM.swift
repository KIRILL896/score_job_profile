

import UIKit
import RxSwift
import RxCocoa
import Contacts

extension ProfileModule.Detail {
  class ViewModel: BaseViewModel {
    var loading : Driver<Bool>!
    var errorOccured : Driver<String>!
    let isSelfScoringVisible = PublishSubject<Bool>()
    var statisticData = PublishSubject<(Int, Double)>()
    let user: Observable<UserData>
    let router: ProfileModule.Router
    let deps: Dependencies
    var scoredTapedValue:String = ""
    
    let scroingTapped:PublishSubject<String> = PublishSubject<String>()
    
    
    init(router: ProfileModule.Router, deps: Dependencies) {
      self.deps = deps
      self.router = router
      self.user = deps.profileService.profileObservable.compactMap { $0 }
    }
  }
}

// MARK: - all dependencies
extension ProfileModule.Detail.ViewModel {
  struct Bindings {
    let redoAction: Driver<Void>
    let seeStory: Driver<Void>
    let selfScoring: Driver<Void>
    let deleteProfile: Driver<Void>
    let goToQr: Driver<Void>
    let enableLinkdn: Driver<Bool>
    let givenScoredHistory: Driver<Bool>
    let seeDetailedScore: Driver<Bool>
    let confirmChanges: Driver<Void>
    let traitsVisibility:Driver<String>
    let displayWebPage:Driver<String>
    let logOutProfile:Driver<Void>
    let scoringHistory: Driver<Void>
    let myProfile: Driver<Void>
    
  }
  
  struct Dependencies {
    let profileService: ProfileService
    let loginService: LoginService
    let statisticService: StatisticService
    let scoreService: ScoreService
    let notificationService:NotificationService_
    let usersService: UsersService
  }
}

// MARK: - input
extension ProfileModule.Detail.ViewModel {

    
  func configure(with bindings: Bindings) {
    let activityTracker = ActivityIndicator()
    let errorTracker = ErrorTracker()
    
    
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

    bindings.redoAction.asObservable().bind { [unowned self] _ in
      self.router.redo()
    }.disposed(by: disposeBag)
    
    
    bindings
        .seeStory
        .asObservable()
        .withLatestFrom(user)
        .flatMapLatest { data -> Observable<(UserData,[Rate])> in
            return self
                    .deps
                    .scoreService
                    .observeRates(ofMe: data.userId)
                    .asObservable()
                    .map {
                        return (data,$0)
                    }
            
            
        }.bind { [unowned self] data in
            //openRateDetail
            //let rates = data.1
            let user_ = data.0
            let scoreCount = user_.scoreCount == nil ? 0 : user_.scoreCount!
            if scoreCount < 10 {
                self.router.openMyScoreValue()
            } else {
                self.router.seeMyScore()//self.router.seeStory(rates: rates)
            }
        }.disposed(by: disposeBag)
    
    
    self
        .deps
        .notificationService
        .observeNotifications(for: deps.profileService.authCode ?? "")
        .asObservable()
        .trackError(errorTracker)
        .catchErrorJustReturn([])
        .trackActivity(activityTracker)
        .share()
        .map { notifications -> [Notificatione] in
            
           print("notifications \(notifications)")
          return notifications.filter { $0.notificationStatus }
        }.observeOn(MainScheduler.instance).flatMapLatest { [unowned self] ids -> Observable<([Notificatione],[UserData])> in
            
  
            let ids_ =  ids.map { $0.ownerId }.filter { !$0.isEmpty }
        
            if ids_.count == 0 { return Observable.just(([],[]))}
            return self.deps
              .usersService
              .getUsers(ids: ids_)
              .asObservable()
              .trackError(errorTracker)
              .catchErrorJustReturn([])
              .trackActivity(activityTracker)
              .map{
                return (ids, $0)
              }
        }
        .map {  data -> Int in
            
            var notifications = data.0
            

            notifications = notifications.sorted(by: { $0.created.compare($1.created) == .orderedDescending })
            
            let cells =  notifications.filter {
                return $0.status == false
            }.count
          
            
            return cells
        }.bind {  data in
            
            
            if let appDelegate = UIApplication
                .shared.delegate as? AppDelegate {
                appDelegate
                  .badgeCount
                    .onNext(data)
            }
            

            
        }.disposed(by: disposeBag)
    
    
    
    //scoringHistory
    bindings
        .scoringHistory
        .asObservable()
        .withLatestFrom(user)
        .flatMapLatest { data -> Observable<(UserData,[Rate])> in
            return self
                    .deps
                    .scoreService
                    .observeRates(ofMe: data.userId)
                    .asObservable()
                    .map {
                        return (data,$0)
                    }
            
            
        }.bind { [unowned self] data in
            
            //openRateDetail
            let rates = data.1
         
           
            self.router.seeStory(rates: rates)
          
            
            
        }.disposed(by: disposeBag)
    
    


    bindings.goToQr.asObservable().bind { [unowned self] _ in
      self.router.openQR()
    }.disposed(by: disposeBag)
    
    
    bindings.scoringHistory.asObservable().bind { [unowned self] _ in
        print("scoringHistory")
    }.disposed(by: disposeBag)
    
    bindings.myProfile.asObservable().bind { [unowned self] _ in
        self.router.openMyProfileSetting()
    }.disposed(by: disposeBag)
    
    
    bindings
      .deleteProfile
      .asObservable()
      .bind { [unowned self] _ in
        guard let user = self.deps.profileService.profile else { return }
        self.deps.profileService.reset()
        self.deps.loginService.markAsDeleted(userId: user.userId, userPhone: user.phone)
        (UIApplication.shared.delegate as? AppDelegate)?.mainRouter?.start()
      }
      .disposed(by: disposeBag)

    let isAvailableSelfScoring = user.asObservable()
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
          .trackActivity(activityTracker)
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
        user.asObservable(),
        isAvailableSelfScoring.asObservable()
    )
    
    
    
    self
        .scroingTapped
        .asObservable()
        .withLatestFrom(scoreUselfData) {return ($0, $1)}
        .flatMapLatest {[unowned self] data -> Observable<((UserData, (pro: Bool, social: Bool)),[Rate])> in
          
          let data_ = data.1
          self.scoredTapedValue = data.0
            
            
          return self.deps
              .scoreService
              .observeRates(byMe: self.deps.profileService.authCode!)
              .asObservable()
              .map {return (data_,$0)}
        }
        .flatMapLatest { data -> Observable<((UserData, (pro: Bool, social: Bool)), [RateType], [Rate])?> in
            
           
            var search_cat_question:Int = 0
            
            if self.scoredTapedValue == "social" {
                  search_cat_question = 1
            } else {
                search_cat_question = 2
            }
         
          
            
          let category_num = data.1.count > 0 ? data.1[0].category : 0
            
          let categoty_type =  RateCategory.return_category(value: search_cat_question)
          
        
            
          return self.deps
              .scoreService
              .get(for: categoty_type)
              .map {return (data.0,$0,data.1)}
              .asObservable()
              .share()
              .trackActivity(activityTracker)
              .trackError(errorTracker)
              .catchErrorJustReturn(nil)
        }
        .bind { [unowned self] data in
          
          guard let data = data else {return}
          
          print("self rates \(data.2)")
          print("GOT data \(data)")
          print("trying so .selfScoring")
          let profile = data.0.0
          let availability = data.0.1
            self.router.startSelfScoring(user: profile, isAvailablePro: availability.pro, isAvailableSocial: availability.social, rates:data.1, selfScoreCount:data.2, valueTapped:self.scoredTapedValue)
          print("started .selfScoring")
        }.disposed(by: disposeBag)
        
    
    
    


    let changes = Observable.combineLatest(
      user,
      bindings.enableLinkdn.asObservable(),
      bindings.givenScoredHistory.asObservable(),
      bindings.seeDetailedScore.asObservable(),
      bindings.traitsVisibility.asObservable(),
      bindings.displayWebPage.asObservable()
    )
    
    bindings
      .confirmChanges
      .asObservable()
      .withLatestFrom(changes)
      .bind { [unowned self] changes in
        let lastUser = changes.0
        let linkedinEnabled = changes.1
        let givenScoredHistory = changes.2
        let visibleTraits = changes.3
        let traitsAll = changes.4
        let displayStatus = changes.5
        print("updated with params \(traitsAll)")
        lastUser.set_traits_visibility_from_string(value:traitsAll)
        lastUser.rateHistory = givenScoredHistory
        lastUser.visibleTraits = visibleTraits
        lastUser.displayWebPage = lastUser.get_display_page_Value(value: displayStatus)
        if lastUser.hiddenFields.contains("linkedin") {
          lastUser.hiddenFields.removeAll(where: { $0 == "linkedin"})
        } else {
          lastUser.hiddenFields.append("linkedin")
        }
        let params = lastUser.toUpdatedParams()
        
        print("params as \(params["traitsVisibility"])")
        self.deps.profileService.update(by: params)
    
      }.disposed(by: disposeBag)

    guard let usr = deps.profileService.profile else { return }

    
    self.deps
        .scoreService
        .observeRates(ofMe: usr.userId)
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
            print("rates are \(rates_are)")
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
            let rateStat:(Int, Double) = rates_are.count == 0 ? (0,0.0) :(percent, rate_ids)
            self?.statisticData.onNext(rateStat)
        }.disposed(by: disposeBag)
    

  }
}
