//
//  CheckCodeVM.swift
//  imscored
//
//  Created by Влада Кузнецова on 20.07.2020.
//  Copyright © 2020 Winfox. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

struct CheckCodeViewModelDependencies {
  let loginService: LoginService
  let profileStorage: ProfileService
  let authWay: AuthCredentials
  let phone: String
  let loggedIn: AnyObserver<Void>
  let didSkip: AnyObserver<Void>
}

struct CheckCodeViewModelBindings {
  let didPressContinue : Driver<Void>
  let didPressRepeat : Driver<Void>
  let didPressSkipAuthorization : Driver<Void>
  let code: Driver<String>
  let backTapped:Driver<Void>
}

class CheckCodeViewModel: BaseViewModel {
  var loading : Driver<Bool>!
  var errorOccured : Driver<String>!

  var canContinue: Driver<Bool>!
  
  let router: LoginRouter
  let deps: CheckCodeViewModelDependencies

  init(router: LoginRouter, deps: CheckCodeViewModelDependencies) {
    self.deps = deps
    self.router = router
  }

    
  func back() {
    self.router.back_()
  }
    
    
  func configure(with bindings: CheckCodeViewModelBindings) {
    let activityTracker = ActivityIndicator()
    let errorTracker = ErrorTracker()

    bindings.backTapped.asObservable().bind{ _ in
        self.router.back_()
    }.disposed(by: disposeBag)
        
    canContinue = bindings
      .code
      .map { $0.count == Constants.smsConfirmationCodeLength }
      .asDriver()
    
    bindings //.bind(to: deps.didSkip)
      .didPressSkipAuthorization
      .asObservable()
      .bind(to: deps.didSkip)
      .disposed(by: disposeBag)
    
    bindings
      .didPressRepeat
      .asObservable()
      .flatMapLatest { [unowned self] _ in
        return self.deps
          .loginService
          .sendSMSConfirmation(phone: self.deps.phone)
          .asObservable()
          .share()
          .trackError(errorTracker)
          .catchErrorJustReturn("")
          .trackActivity(activityTracker)

      }
      .bind { _ in
        print("code sended")
      }
      .disposed(by: disposeBag)

    let verificationCodeObservable = deps
      .loginService
      .sendSMSConfirmation(phone: deps.phone)
      .share()
      .trackError(errorTracker)
      .catchErrorJustReturn("")
      .trackActivity(activityTracker)
      .observeOn(MainScheduler.instance)

    
    
    /*
     
     checkSmsCode
     OK IS haGhIvktYEM7My77Wc58EIkQhtE3
     trying to set AuthWay
     STARTING REGISTER some, lue , +78888888888, true, haGhIvktYEM7My77Wc58EIkQhtE3
     TRUE WHEN REGISTING

     
     
     checkSmsCode
     OK IS haGhIvktYEM7My77Wc58EIkQhtE3
     get auth code haGhIvktYEM7My77Wc58EIkQhtE3
     
     
     */
    bindings
      .didPressContinue
      .asObservable()
      .withLatestFrom(bindings.code.asObservable())
      .withLatestFrom(verificationCodeObservable.asObservable()) { code, ver in
        return (userCode: code, verificationCode: ver)
      }
      .flatMapLatest { [unowned self] tuple -> Observable<String> in
        return self.deps.loginService.checkSmsCode(
          verificationID: tuple.verificationCode,
          code: tuple.userCode
        )
        .share()
        .trackError(errorTracker)
        .catchError{ [weak self] error -> Observable<String> in
            print("error was occured \(error.localizedDescription)")
            return .empty()
        }
        .trackActivity(activityTracker)
      }
      .flatMapLatest { [unowned self] uid in
        
        
        return self.deps
          .authWay
          .auth(token: uid, loginService: self.deps.loginService)
      }.flatMapLatest { [unowned self] data -> Observable<(Bool, String)?> in
        
        return self
            .deps
            .loginService
            .checkIsBlocked(authCode: data)
            .asObservable()
            .map {
                return ($0, data)
            }
            .trackError(errorTracker)
            .catchErrorJustReturn(nil)
            .trackActivity(activityTracker)
                    
        
      }
      .bind { [unowned self] loginedId_ in
        guard let data = loginedId_ else {return}
        let loginedId = data.1
        
        
        print("get auth code \(loginedId)")
        UserDefaults.standard.set(false, forKey: ContentSettings.Keys.wasSkipAuthorization.rawValue)
        UserDefaults.standard.synchronize()
        //ProfileService.setProfileStrorage(auth: loginedId)
        self.deps.profileStorage.authCode = loginedId
        self.deps.loggedIn.onNext(())
      }
      .disposed(by: disposeBag)
      loading = activityTracker.asDriver()
      errorOccured = errorTracker
      .filter {
        if case APIError.stateError = $0 {
          return false
        }
        return true
      }
      .asDriver()
      .map {  $0.localizedDescription }
  }
}
