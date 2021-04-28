//
//  SignUpVM.swift
//  imscored
//
//  Created by Влада Кузнецова on 20.07.2020.
//  Copyright © 2020 Winfox. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

enum Gender {
  case male
  case female
  case unspecified
}

struct SignUpViewModelDependencies {
  let loginService: LoginService
  let loggedIn: AnyObserver<Void>
  let didSkip: AnyObserver<Void>
}

struct SignUpViewModelBindings {
  let didPressSignIn : Driver<Void>
  let didPressSignUp : Driver<Void>
  let didPressSkipAuthorization : Driver<Void>
  
  let phone : Driver<String>
  let name : Driver<String>
  let surname : Driver<String>
  let gender: Driver<Gender>

  let didPressPolicy: Driver<Void>
  let didPressAgree: Driver<Bool>
  let code: Driver<String>
}

class SignUpViewModel: BaseViewModel {
  var loading: Driver<Bool>!
  var warnings = PublishSubject<String>()
  var errorOccured: Driver<String>!
  
  var canContinue: Driver<Bool>!

  var firstTelephone:String
    
    
  let termsServiceClicked = PublishSubject<Void>()
  let rulesServiceClicked = PublishSubject<Void>()

    
    
  let router: LoginRouter
  let deps: SignUpViewModelDependencies
    
    
    enum code_valid {
        case exist
        case deleted
        case ok
    }
    
  var code_request:code_valid = .ok
    
    init(router: LoginRouter, deps: SignUpViewModelDependencies, telephone:String) {
        self.deps = deps
        self.firstTelephone = telephone
        self.router = router
        print("TELEPHONE is \(telephone)")
    
    }

  func configure(with bindings: SignUpViewModelBindings) {
    let activityTracker = ActivityIndicator()
    let errorTracker = ErrorTracker()
    
    
  
    let credentials = Observable.combineLatest(
        bindings.phone.asObservable(),
        bindings.name.asObservable(),
        bindings.surname.asObservable(),
        bindings.gender.asObservable(),
        bindings.didPressAgree.asObservable(),
        bindings.code.asObservable()
      )

    
    
    canContinue = credentials.asObservable()
        .map { phone, name, surname, gender, agree, code -> Bool in
            if name.isEmpty { return false }
            if surname.isEmpty { return false}
            if agree == false {return false}
            if phone.count <= 9 { return false }
            return true
        }.asDriver(onErrorJustReturn: false)
    
    
    
    
    bindings
      .didPressSignUp
      .asObservable()
      .withLatestFrom(Observable.combineLatest(bindings.code.asObservable(), bindings.phone.asObservable()))
      .map { (code, phone) in
        return phone
      }
      .observeOn(MainScheduler.instance)
      .flatMapLatest { [unowned self] phone in

        
        
        return self.deps
          .loginService
          .checkIsExist(phone: phone)
          .asObservable()
          .share()
          .trackError(errorTracker)
          .catchErrorJustReturn(LoginService.ExistProfile.exist)
          .trackActivity(activityTracker)
      }
      .map { [weak self] (isHave) -> Bool in
        self?.code_request = .ok
        if isHave == .exist {
            self?.warnings.onNext(L10n.Errors.alreadyRegistered)
            self?.code_request = .exist
        } else if isHave == .deleted {
            self?.warnings.onNext(L10n.Errors.restore)
            self?.code_request = .deleted
        }
        return true
      }
      .withLatestFrom(credentials)
      .bind { [unowned self] phone, name, surname, gender, agree, code in
        
        
        let phone_ = code.trimmingCharacters(in: .whitespaces) + phone.trimmingCharacters(in: .whitespaces)
        

        
        if self.code_request == .ok {
            
        
            
            self.router.openCodeConfirmation(
              credentials: SignUpAuth(
                number: phone_,
                name: name,
                surname: surname,
                isMale: gender == .male
              ),
              loggedIn: self.deps.loggedIn,
              didSkip: self.deps.didSkip
            )
        }
        
        
      }
      .disposed(by: disposeBag)
    

    self.termsServiceClicked.asObservable().bind { [unowned self] _ in
        self.router.openTermsOfUsePolicy()
    }.disposed(by:disposeBag)
    
    
    self.rulesServiceClicked.asObservable().bind { [unowned self] _ in
        

        self.router.openProcessingPolicy()
        
    }.disposed(by: disposeBag)
    
    bindings
      .didPressSignIn
      .asObservable()
      .bind { [unowned self] _ in
        
        print("pressed didPressSignIn")
        
        self.router.closeTop()
      }
      .disposed(by: disposeBag)
    
    /*
    bindings.didPressSkipAuthorization.asObservable().bind { _ in
        
        print("didPressSkipAuthorization was set")
    }.disposed(by: disposeBag) */
    
    
    bindings
      .didPressSkipAuthorization
      .asObservable()
      .bind(to: deps.didSkip)
      .disposed(by: disposeBag)
    
    
    /*
    bindings
      .didPressPolicy
      .asObservable()
      .bind { [unowned self] _ in
        self.router.openProcessingPolicy()
      }
      .disposed(by: disposeBag) */
    
    loading = activityTracker.asDriver()
    errorOccured = errorTracker
      .filter {
        if case APIError.stateError = $0 {
            return false
        }
        return true
      }
    .asDriver()
    .map { $0.localizedDescription }

  }
}
