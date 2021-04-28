

import UIKit
import RxSwift
import RxCocoa

extension Score.List {
  class ViewModel: BaseViewModel {
    var loading : Driver<Bool>!
    var errorOccured : Driver<String>!
    
    let router: Score.Router
    let deps: Dependencies
    var models: Observable<[Score.ScoreElem]>!

    init(router: Score.Router, deps: Dependencies) {
      self.deps = deps
      self.router = router
    }
  }
}

// MARK: - all dependencies
extension Score.List.ViewModel {
  struct Bindings {
    let done: Driver<Void>
  }
  struct Dependencies {
    let profileService: ProfileService
  }
}

// MARK: - input
extension Score.List.ViewModel {
  func configure(with bindings: Bindings) {
    let lastValues = (try? router.scored.value()) ?? []
    models = Observable.just(lastValues)
    
    bindings.done
      .asObservable()
      .bind { [unowned self] _ in
        self.router.scored.onNext(lastValues)
        if let _ = self.deps.profileService.authCode {
          self.router.showResults()
        } else {
          self.router.pleaseLogin()
        }
      }
      .disposed(by: disposeBag)
  }
}
