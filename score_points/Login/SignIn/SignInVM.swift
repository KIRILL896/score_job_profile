//
//  SignInVM.swift
//  imscored
//
//  Created by Влада Кузнецова on 20.07.2020.
//  Copyright © 2020 Winfox. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

struct SignInViewModelDependencies {
  let loginService: LoginService
}





struct SignInViewModelBindings {
  let phone : Driver<String>
  let didPressLogin : Driver<Void>
  let didPressSignUp : Driver<Void>
  let didPressSkipAuthorization : Driver<Void>
}

class SignInViewModel: BaseViewModel {
  var loading : Driver<Bool>!
  var errorOccured : Driver<String>!

  var canLogIn: Observable<Bool>!
  var lastPhone: String = ""
  
  var loggedIn : Driver<Void>
  var didSkipSignIn : Driver<Void>
  private let didSkipSignInSubject = PublishSubject<Void>()
  private let didLoggedInSubject = PublishSubject<Void>()

  let router: LoginRouter
  let deps: SignInViewModelDependencies

  init(router: LoginRouter, deps: SignInViewModelDependencies) {
    self.deps = deps
    self.router = router
    loggedIn = didLoggedInSubject.asDriverOnErrorJustComplete()
    didSkipSignIn = didSkipSignInSubject.asDriverOnErrorJustComplete()
  }

  func configure(with bindings: SignInViewModelBindings) {
    let activityTracker = ActivityIndicator()
    let errorTracker = ErrorTracker()
    let errorListener = PublishSubject<Error>()
    
    

    self.canLogIn = bindings.phone.asObservable().map({return $0.count >= 10})

    bindings.didPressSkipAuthorization.asObservable().bind(to: self.didSkipSignInSubject).disposed(by: disposeBag)
    

    bindings.phone.asObservable().bind { [unowned self] num in
        self.lastPhone = num
    }.disposed(by: disposeBag)
    
    bindings
      .didPressLogin
      .asObservable()
      .withLatestFrom(bindings.phone.asObservable())
      //.observeOn(MainScheduler.instance)
      .flatMapLatest { [unowned self] phone in
        
        
        
        return self.deps
          .loginService
          .checkIsExist(phone: phone)
          .asObservable()
          .share()
          .trackError(errorTracker)
          .trackActivity(activityTracker)
      }
      .bind { [unowned self] isHave in
        if isHave == .notExist {
          errorListener.onNext(RuntimeError(L10n.Errors.noRegistered))
        } else if isHave == .deleted {
          errorListener.onNext(RuntimeError(L10n.Errors.deleted))
        } else {
          self.router.openCodeConfirmation(
            credentials: SignInAuth(number: self.lastPhone),
            loggedIn: self.didLoggedInSubject.asObserver(),
            didSkip: self.didSkipSignInSubject.asObserver()
          )
        }
      }
      .disposed(by: disposeBag)
    
    bindings
      .didPressSignUp
      .asObservable()
      .bind { [unowned self] _ in
        
        let phone_ = self.lastPhone.contains("+") ? String(lastPhone.dropFirst()) : self.lastPhone
        
        self.router.openSignUp(
          loggedIn: self.didLoggedInSubject.asObserver(),
          didSkip: self.didSkipSignInSubject.asObserver(),
          lastPhone:phone_
        )
      }
      .disposed(by: disposeBag)
    
    loading = activityTracker.asDriver()
    
    let errorTrackerFiltered = errorTracker
    .filter {
      if case APIError.stateError = $0 {
          return false
      }
      return true
    }
    
    errorOccured = Observable
      .merge(
        errorTrackerFiltered.asObservable(),
        errorListener.asObservable())
      .asDriverOnErrorJustComplete()
      .map { $0.localizedDescription }
  }
}

