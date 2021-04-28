

import UIKit
import RxSwift
import RxCocoa

extension ProfileModule {
  class RateHistory {}
}

extension ProfileModule.RateHistory {
  class ViewModel: BaseViewModel {
    var loading : Driver<Bool>!
    var errorOccured : Driver<String>!
    
    var meScored: PublishSubject<[RateHistoryCellModel]>! = PublishSubject<[RateHistoryCellModel]>()//Observable.just([])
    var scoredByMe: PublishSubject<[RateHistoryCellModel]>! = PublishSubject<[RateHistoryCellModel]>()//Observable.just([])

    let router: ProfileModule.Router
    let deps: Dependencies

    init(router: ProfileModule.Router, deps: Dependencies) {
      self.deps = deps
      self.router = router
    }
  }
}

// MARK: - all dependencies
extension ProfileModule.RateHistory.ViewModel {
  struct Bindings {
    let myRateDeleted: Driver<RateHistoryCellModel>
    let myRateSelected: Driver<RateHistoryCellModel>
    let otherRateSelected: Driver<RateHistoryCellModel>
  }
  
  struct Dependencies {
    let usersService: UsersService
    let scoreService: ScoreService
    let profileService: ProfileService
  }
}

// MARK: - input
extension ProfileModule.RateHistory.ViewModel {
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

    guard let authCode = self.deps.profileService.authCode,
    let profile = self.deps.profileService.profile else { return }
    
    print("AUTHCODE \(authCode)")
    print("PROFILE \(profile.rateHistory)")
    

        
 
        
     // scoredByMe =
        self.deps
        .scoreService
        .observeRates_(ofMe: authCode)
        .flatMap { [unowned self] rates -> Single<(users: [UserData], rates: [Rate])> in
            
            print("[rates scoredByMe]", rates)

            let ratedIds = rates.map { $0.ownerId }
            return self.deps
                .usersService
                .getUsers(ids: ratedIds)
                .map { return (users: $0, rates: rates) }
        }
        .asObservable()
        .map { data -> [RateHistoryCellModel] in
          
          
          //print("[scoredByMe] \(data)")
          
          let usersByIds: [String : UserData] = Array<UserData>
            .toDict(elms: data.users) {
              return $0.userId
            }
          
          //("usersByIds \(usersByIds)")
          
            let score = data.rates.compactMap { rate ->   RateHistoryCellModel? in
              guard let usr = usersByIds[rate.ownerId] else { return nil }
            
              if rate.userId == self.deps.profileService.authCode! && rate.ownerId == self.deps.profileService.authCode! {return nil}
              //if rate.userId == self.deps.profileService.authCode! {return nil}
              if rate.hiddenFields != nil {
                return nil
              }
            return RateHistoryCellModel(type:"scoredByMe", rate: rate, user: usr, shown: false)
          }
          
            
            let filtured = score.sorted { return $0.rate.created > $1.rate.created}
          
          //print("SCORES \(score.count)")
          
          return filtured
        }
        .share()
        .trackError(errorTracker)
        .catchErrorJustReturn([])
        .trackActivity(activityTracker)
        .bind { [weak self] data in
            self?.scoredByMe.onNext(data)
        }.disposed(by: disposeBag)

    //meScored =
        self.deps
          .scoreService
          .observeRates_(byMe: authCode)
          .flatMap { [unowned self] rates -> Single<(users: [UserData], rates: [Rate])> in
            
            print("[rates meScored]", rates)
            
            let ratedIds = rates.map { $0.userId }
            return self.deps
              .usersService
              .getUsers(ids: ratedIds)
              .map { return (users: $0, rates: rates) }
          }
        .asObservable()
          .map { [weak self ] data -> [RateHistoryCellModel] in
            
            print("[meScored] \(data)")

            
            let usersByIds: [String : UserData] = Array<UserData>
              .toDict(elms: data.users) {
                return $0.userId
              }
            
            //print("scoredByMe usersByIds \(usersByIds)")
              
            let score = data.rates.compactMap { rate -> RateHistoryCellModel? in
              guard let usr = usersByIds[rate.userId] else { return nil }
              //if !rate.status { return nil }
              if rate.userId == self?.deps.profileService.authCode! && rate.ownerId == self?.deps.profileService.authCode! {return nil}
              if rate.hiddenFields != nil {
                  return nil
              }
                return RateHistoryCellModel(type:"meScored", rate: rate, user: usr, shown: false)
            }
              
            //print("scoredByMe score \(score.count)")
              
             let filtured = score.sorted { return $0.rate.created > $1.rate.created}
          
              //print("SCORES \(score.count)")
              
              return filtured
        }
        .share()
        .trackError(errorTracker)
        .catchErrorJustReturn([])
        .trackActivity(activityTracker)
            .bind { [weak self] data in
                self?.meScored.onNext(data)
            }.disposed(by: disposeBag)
      //}
    
    

    bindings
      .myRateDeleted
      .asObservable()
        .withLatestFrom(meScored) {return ($0, $1)}
      .bind { [unowned self] data in
        let cellModel = data.0
        var cells = data.1
        var rate = cellModel.rate
        rate.status = false
        rate.hiddenFieldsParams(id: cellModel.rate.ownerId)
        
        print(cellModel.rate.id, cellModel.user.userId, cellModel.rate.ownerId)
        
        UIWindow.simulateLoading()
        self.deps.scoreService.updateScoreHistory(with: rate.toParams(), for: rate.id)
        
        for (i,e) in cells.enumerated() {
            if e.rate.id == cellModel.rate.id && e.rate.ownerId == cellModel.rate.ownerId {
                cells.remove(at: i)//cells[i].rate.hiddenFields = rate.hiddenFields
                break
            }
        }
        
        self.meScored.onNext(cells)
        
      }
      .disposed(by: disposeBag)

    bindings
      .myRateSelected
      .asObservable()
      .withLatestFrom(meScored) {return ($0, $1)}
      .flatMapLatest { [unowned self] data ->  Observable<([Score.ScoreElem],RateHistoryCellModel,[RateHistoryCellModel])> in
        let model = data.0
        let models = data.1
        let category = RateCategory.return_category(value: model.rate.category)
        return self
                    .deps
                    .scoreService
                    .get(for: category)
                    .observeOn(MainScheduler.instance)
                    .asObservable()
                    .share()
                    .trackActivity(activityTracker)
                    .trackError(errorTracker)
                    .catchErrorJustReturn([])
                    .map {  rateTypes -> ([Score.ScoreElem],RateHistoryCellModel,[RateHistoryCellModel]) in
                      let scoreRes = model.rate.scores
                      let scoreResByIds: [String : RateScore] = Array<RateScore>
                        .toDict(elms: scoreRes) {
                          return $0.id
                      }
                      var results = [Score.ScoreElem]()
                      for question in rateTypes {
                        let id = question.id
                        if scoreResByIds[id] == nil { continue }
                        let scoreElem = Score.ScoreElem(question: question, evaluated: scoreResByIds[id]?.value)
                        results.append(scoreElem)
                      }

                      return (results,model, models)
                  }
        
       }
      .bind { [unowned self] data in
        let model = data.1
        var models = data.2
        if model.shown == true  {
            var filter_models = models.filter { return $0.elems.count == 0}
            for (i,_) in filter_models.enumerated() {
                filter_models[i].shown = false
                filter_models[i].elems = []
            }
            self.meScored.onNext(filter_models)
        } else if model.shown == false{
            let score_elems = data.0
            guard let index = models.firstIndex(of: model) else {return}
            models[index].shown = true
            let new_model = RateHistoryCellModel(type: model.type, rate: model.rate, user: model.user, shown: true, elems: score_elems)
            models.insert(new_model, at: index + 1)
            self.meScored.onNext(models)
        }
    }
    .disposed(by: disposeBag)
    

  }
}
