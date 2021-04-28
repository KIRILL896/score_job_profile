//
//  LoginRouter.swift
//  imscored
//
//  Created by Влада Кузнецова on 20.07.2020.
//  Copyright © 2020 Winfox. All rights reserved.
//

import Foundation
import RxSwift
import Hero

class LoginRouter: BaseRouter {
  func openSignIn(from: UIViewController, after: @escaping () -> ()) {
    let vc = SignInVC.instanceFromStoryboard()
    vc.canSkip = true
    let deps = SignInViewModelDependencies(loginService: LoginService())
    let vm = SignInViewModel(router: self, deps: deps)
    self.sourceViewController = vc
    let nvc = UINavigationController(rootViewController: vc)
    
    vm.loggedIn
      .drive(onNext : { [weak nvc = nvc] in
        after()
        nvc?.dismiss(animated: true, completion: nil)
      })
      .disposed(by: disposeBag)

    vc.viewModel = vm
    vc.modalPresentationStyle = .fullScreen
    from.present(vc, animated: true, completion: nil)
  }
    
    func openSignIn_(from: UIViewController, after: @escaping () -> ()) {
      let vc = SignInVC.instanceFromStoryboard()
      vc.canSkip = true
      let deps = SignInViewModelDependencies(loginService: LoginService())
      let vm = SignInViewModel(router: self, deps: deps)
      self.sourceViewController = from
      vc.viewModel = vm
      
      from.dismiss(animated: true, completion: nil)
      //sourceViewController?.navigationController?.pushViewController(vc, animated: true)
        //sourceViewController?.navigationController.present(vc, animated: true, completion: nil)
      /*self.sourceViewController = vc
      let nvc = UINavigationController(rootViewController: vc)
      
      vm.loggedIn
        .drive(onNext : { [weak nvc = nvc] in
          after()
          nvc?.dismiss(animated: true, completion: nil)
        })
        .disposed(by: disposeBag)

      vc.viewModel = vm
      //vc.modalPresentationStyle = .fullScreen
      //from.navigationController?.present(vc, animated: true, completion: nil)
      //sourceViewController?.navigationController?.pushViewController(vc, animated: true)
      sourceViewController?.present(vc, animated: true, completion: nil)
      //topVC()?.present(vc, animated: true, completion: nil)
      //from.present(nvc, animated: true, completion: nil)*/
    }
    
  
    func openSignUp(loggedIn: AnyObserver<Void>, didSkip: AnyObserver<Void>, lastPhone:String?) {
        
        
        print("lastPhobe is \(lastPhone)")
            
        let vc = SignUpVC.instanceFromStoryboard()
        let deps = SignUpViewModelDependencies(
          loginService: LoginService(),
          loggedIn: loggedIn,
          didSkip: didSkip)
        
        let phone = lastPhone == nil ? "" : lastPhone!
        let vm = SignUpViewModel(router: self, deps: deps, telephone: phone)
        vc.viewModel = vm
        vc.modalPresentationStyle = .fullScreen
        sourceViewController?.hero.isEnabled = true
        vc.hero.isEnabled = true
        //sourceViewController?.navigationController?.pushViewController(vc, animated: false)
        sourceViewController?.present(vc, animated: true, completion: nil)
  }
  
    
    func back_() {
        topVC()?.dismiss(animated: false, completion: nil)
    }
    
  func openCodeConfirmation(credentials: AuthCredentials, loggedIn: AnyObserver<Void>, didSkip: AnyObserver<Void>) {
    
    let vc = CheckCodeVC.instanceFromStoryboard()
    let deps = CheckCodeViewModelDependencies(
      loginService: LoginService(),
      profileStorage: ProfileService.shared,
      authWay: credentials,
      phone: credentials.number,
      loggedIn: loggedIn,
      didSkip: didSkip)
    let vm = CheckCodeViewModel(router: self, deps: deps)
    vc.viewModel = vm
    vc.modalPresentationStyle = .fullScreen
    
    sourceViewController?.hero.isEnabled = true
    vc.hero.isEnabled = true
    
    //sourceViewController?.navigationController?.pushViewController(vc, animated: false)
    
    topVC()?.present(vc, animated: true, completion: nil)
  }
  
  func openProcessingPolicy() {
    
    
    let vc = Settings.Privacy.ViewController()
    let router = Settings.Router(sourceViewController: vc)
    let deps = Settings.Privacy.ViewModel.Dependencies()
    let vm = Settings.Privacy.ViewModel(router: router, deps: deps)
    vc.viewModel = vm
    topVC()?.present(vc, animated: true, completion: nil)

//    sourceViewController?.present(vc, animated: true, completion: nil)

    //sourceViewController?.navigationController?.pushViewController(vc, animated: true)
  }
    
    
    
    func openTermsOfUsePolicy() {
      
      
      let vc = Settings.TermsOfUse.ViewController()
      let router = Settings.Router(sourceViewController: vc)
      let deps = Settings.TermsOfUse.ViewModel.Dependencies()
      let vm = Settings.TermsOfUse.ViewModel(router: router, deps: deps)
      vc.viewModel = vm
      topVC()?.present(vc, animated: true, completion: nil)

  //    sourceViewController?.present(vc, animated: true, completion: nil)

      //sourceViewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
}
