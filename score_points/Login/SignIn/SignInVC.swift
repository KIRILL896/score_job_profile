//
//  SignInVC.swift
//  imscored
//
//  Created by Renat Galiamov on 15.05.2020.
//  Copyright © 2020 Renat Galiamov. All rights reserved.
//

import UIKit
import SimpleButton
import RxSwift
import RxCocoa
import RxKeyboard
import InputMask
import FlagPhoneNumber

class SignInVC : BaseViewController {
  
  let disposeBag = DisposeBag()
  
  @IBOutlet weak var btnSkip: UIButton!
  @IBOutlet weak var vSkipContainer: UIView!
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var btnSignUp: UIButton!
  @IBOutlet weak var btnSignIn: SimpleButton!
  @IBOutlet weak var tfPhone: FPNTextField!
  @IBOutlet weak var lbTitle: UILabel!
  
  var canSkip: Bool = true
  @IBOutlet weak var vPhoneContainer: UIView!
  
  private var phoneTextListener : MaskedTextFieldDelegate!
  var viewModel: SignInViewModel!
  
  override func viewDidLoad() {
    isHideNavbar = true
    super.viewDidLoad()
    
    setupViews()
    setupViewModelInput()
    setupViewModelOutput()
  }
  
    
    
  func setupViewModelInput() {
    
    
    let phone_ = Driver.combineLatest(tfPhone.phoneCodeTextField.rx.text.orEmpty.asDriverOnErrorJustComplete(), tfPhone.rx.text.orEmpty.asDriverOnErrorJustComplete()).map { code, pho in
        return code + pho
    }.asDriver()
    
    let bindings = SignInViewModelBindings(
      phone: phone_,
      didPressLogin: btnSignIn.rx.tap.asDriver(),
      didPressSignUp: btnSignUp.rx.tap.asDriver(),
      didPressSkipAuthorization: btnSkip.rx.tap.asDriver())
    viewModel.configure(with: bindings)
    
    /*
    tfPhone.rx.controlEvent([.allEvents]).withLatestFrom(tfPhone.rx.text.orEmpty).map {return $0}.asObservable().bind { [unowned self] value in
        if value == "" {
          self.tfPhone.text = "+"
        }
    }.disposed(by: disposeBag) */
  }
  
    
    
    
    
  func setupViewModelOutput() {
    viewModel.canLogIn.asObservable().bind(to: btnSignIn.rx.isEnabled).disposed(by: disposeBag)
    viewModel
      .loading
      .drive(onNext : { [weak self] loading in
        if loading {
            self?.showActivityHUD()
        } else {
            self?.hideActivityHUD()
        }
      })
      .disposed(by: disposeBag)
    
    viewModel
      .errorOccured
      .drive(onNext : { [weak self] error in
        self?.showErrorToast(with: error)
      })
      .disposed(by: disposeBag)
    
    RxKeyboard.instance
      .visibleHeight
      .drive(onNext: {[weak self] keyboardVisibleHeight in
      if keyboardVisibleHeight == 0 {
        self?.scrollView.contentInset.bottom = 0
      } else {
        let initialContentOffset = self?.scrollView.contentOffset ?? CGPoint.zero
        self?.scrollView.contentOffset = CGPoint(x: initialContentOffset.x, y: initialContentOffset.y + 120.0)
        self?.scrollView.contentInset.bottom = keyboardVisibleHeight
      }
    }).disposed(by: disposeBag)
    
    
    

    
  }

  func setupViews() {
    lbTitle.text = L10n.Login.signinTitle
    
    scrollView.delaysContentTouches = false
    
    vSkipContainer.layer.cornerRadius = 12
    vSkipContainer.layer.masksToBounds = true
    btnSkip.setTitle(L10n.Common.skip.uppercased(), for: .normal)
    vSkipContainer.isHidden = !canSkip
    
    btnSignUp.setTitle(L10n.Login.signupButtonText, for: .normal)
    btnSignIn.setTitle(L10n.Login.signinButtonText, for: .normal)
    
    tfPhone.attributedPlaceholder = NSAttributedString(string: "Mobile Number", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.6)])
    vPhoneContainer.layer.cornerRadius = 8
    vPhoneContainer.layer.masksToBounds = true
    phoneTextListener = MaskedTextFieldDelegate()
    phoneTextListener.primaryMaskFormat = L10n.Login.mask
    tfPhone.placeholder = "Mobile Number"
    
    
    
    tfPhone.delegate = self
    tfPhone.displayMode = .picker
    tfPhone.setFlag(key: .RU)
    tfPhone.textColor = UIColor.white.withAlphaComponent(0.6)
    tfPhone.tintColor = UIColor.white.withAlphaComponent(0.6)
    //tfPhone.delegate = self.phoneTextListener
    //tfPhone.text = "+"
    
    
    btnSignIn.setCornerRadius(8)
    btnSignIn.setBackgroundColor(
      Colors.accentBlue,
      for: .normal,
      animated: true,
      animationDuration: 0.3
    )
    
    btnSignIn.setBackgroundColor(
      Colors.accentBlue.withAlphaComponent(0.5),
      for: .highlighted,
      animated: true,
      animationDuration: 0.3
    )
    
    btnSignIn.setBackgroundColor(
      Colors.gray2,
      for: .disabled,
      animated: true,
      animationDuration: 0.3
    )

    hideKeyboardWhenTappedAround()
    
    
    let skipedStatus = UserDefaults.standard.object(forKey: ContentSettings.Keys.wasSkipAuthorization.rawValue) as? Bool
    guard let skipped_ = skipedStatus else {return}
    if skipped_ == true {
        self.vSkipContainer.isHidden = true
    }
    
    
  }
    
 
    
  
}



extension SignInVC: FPNTextFieldDelegate {
    func fpnDisplayCountryList() {
        print("")
    }
    
    func fpnDidValidatePhoneNumber(textField: FPNTextField, isValid: Bool) {
        
    }
    
    func fpnDidSelectCountry(name: String, dialCode: String, code: String) {
        //.onNext(dialCode) // Output "France", "+33", "FR"
    }
}
