//
//  SignUpVC.swift
//  imscored
//
//  Created by Renat Galiamov on 15.05.2020.
//  Copyright © 2020 Renat Galiamov. All rights reserved.
//

import UIKit
import SimpleButton
import RxSwift
import RxGesture
import RxCocoa
import RxKeyboard
import InputMask
import FlagPhoneNumber


extension String {
    static func format(strings: [String],
                    boldFont: UIFont = UIFont.boldSystemFont(ofSize: 14),
                    boldColor: UIColor = UIColor.blue,
                    inString string: String,
                    font: UIFont = UIFont.systemFont(ofSize: 14),
                    color: UIColor = UIColor.black) -> NSAttributedString {
        let attributedString =
            NSMutableAttributedString(string: string,
                                    attributes: [
                                        NSAttributedString.Key.font: font,
                                        NSAttributedString.Key.foregroundColor: color])
        let boldFontAttribute = [NSAttributedString.Key.font: boldFont, NSAttributedString.Key.foregroundColor: boldColor]
        for bold in strings {
            attributedString.addAttributes(boldFontAttribute, range: (string as NSString).range(of: bold))
        }
        return attributedString
    }
}


class SignUpVC : BaseViewController {
  
  let disposeBag = DisposeBag()
  
  @IBOutlet weak var scrollView: UIScrollView!
  
  @IBOutlet weak var vSkipContainer: UIView!
  @IBOutlet weak var btnSkip: UIButton!
  
  @IBOutlet weak var lbTitle: UILabel!
  
  @IBOutlet weak var vFirstnameContainer: UIView!
  @IBOutlet weak var tfFirstName: TextField!
  
  @IBOutlet weak var vLastnameContainer: UIView!
  @IBOutlet weak var tfLastname: TextField!
  
  @IBOutlet weak var vPhoneContainer: UIView!
  @IBOutlet weak var tfPhone: FPNTextField!
  
  @IBOutlet weak var lbTermsText: UILabel!
  @IBOutlet weak var vCheckbox: UIView!
  @IBOutlet weak var ivCheckbox: UIImageView!
  
  @IBOutlet weak var vGender: UIView!
  
  @IBOutlet weak var vMaleContainer: UIView!
  @IBOutlet weak var ivMaleSymbol: UIImageView!
  @IBOutlet weak var lbMaleText: UILabel!
  
  @IBOutlet weak var vFemale: UIView!
  @IBOutlet weak var ivFemaleSymbol: UIImageView!
  @IBOutlet weak var lbFemaleText: UILabel!
  
  @IBOutlet weak var btnRegister: SimpleButton!
  
  @IBOutlet weak var btnSignupWithLinkedIn: UIButton!
  @IBOutlet weak var btnLogin: UIButton!
  
    
    
    
  let ScrollContryCode_ = ScrollContryCode()
    @IBOutlet weak var contryLabel: UILabel!
    @IBOutlet weak var countryImage: UIImageView!
    private var phoneTextListener : MaskedTextFieldDelegate!
  
  var viewModel: SignUpViewModel!
  var isCheckboxSelected = BehaviorSubject<Bool>(value: false)
  var gender = BehaviorSubject<Gender>(value: .unspecified)

  let termText = "I have read and accept Privacy Policy and Terms of Service"
    
  let term = "Terms of Service"
  let policy = "Privacy Policy"
    
    
  private let code_country = PublishSubject<String>()

  
    
    
    
  override func viewDidLoad() {
    isHideNavbar = true
    
    
    
    super.viewDidLoad()
    
    self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
    self.navigationController?.navigationBar.shadowImage = UIImage()
    self.navigationController?.navigationBar.isTranslucent = true
    
    
    
    self.tfPhone.text = self.viewModel.firstTelephone
    
    tfPhone.delegate = self
    tfPhone.displayMode = .picker
    
    setupViews()
    setupViewModelInput()
    setupViewModelOutput()
    
    
    
    self.tfFirstName.autocapitalizationType = .words
    self.tfLastname.autocapitalizationType = .words
    
    
    
  }
  
  func setupViewModelInput() {
    let termsPressed = lbTermsText.rx
      .tapGesture()
      .when(.recognized)
      .mapToVoid()
      .asDriverOnErrorJustComplete()
    
    
    
    

    
    
    let phone_ = Driver.combineLatest(tfPhone.phoneCodeTextField.rx.text.orEmpty.asDriverOnErrorJustComplete(), tfPhone.rx.text.orEmpty.asDriverOnErrorJustComplete()).map { code, pho in
        return code + pho
    }.asDriver()
    
    
    let bindings = SignUpViewModelBindings(
      didPressSignIn: btnLogin.rx.tap.asDriver(),
      didPressSignUp: btnRegister.rx.tap.asDriver(),
      didPressSkipAuthorization: btnSkip.rx.tap.asDriver(),
      phone: phone_,
      name: tfFirstName.rx.text.orEmpty.asDriver(),
      surname: tfLastname.rx.text.orEmpty.asDriver(),
      gender: gender.asDriverOnErrorJustComplete(),
      didPressPolicy: termsPressed,
      didPressAgree: isCheckboxSelected.asDriverOnErrorJustComplete(),
      code: self.ScrollContryCode_.selectedValue.map {return $0.code}.asDriverOnErrorJustComplete()
    )
    
    viewModel.configure(with: bindings)
    
    

    
    
  }
  
  func setupViewModelOutput() {
    
    tfPhone.rx.controlEvent([.allEvents]).withLatestFrom(tfPhone.rx.text.orEmpty).map {return $0}.asObservable().bind { [unowned self] value in
        if value == "" {
          self.tfPhone.text = ""
        }
    }.disposed(by: disposeBag)
//    viewModel.canLogIn.asObservable().bind(to: btnSignIn.rx.isEnabled).disposed(by: disposeBag)
    
    tfFirstName.rx.controlEvent([.allEvents]).withLatestFrom(tfFirstName.rx.text.orEmpty).map {return $0}.asObservable().bind { [unowned self] value in
        self.tfFirstName.text = self.tfFirstName.text!.capitalizingFirstLetter_()
    }.disposed(by: disposeBag)
    
    
    
    
    tfLastname.rx.controlEvent([.allEvents]).withLatestFrom(tfLastname.rx.text.orEmpty).map {return $0}.asObservable().bind { [unowned self] value in
    
            self.tfLastname.text = self.tfLastname.text!.capitalizingFirstLetter_()
        
    }.disposed(by: disposeBag)

    viewModel.canContinue.asObservable().bind(to: btnRegister.rx.isEnabled).disposed(by: disposeBag)


    
    
    
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
    

    
    viewModel
      .warnings
      .observeOn(MainScheduler.instance)
      .bind(onNext : { [weak self] error in
        self?.showWarningToast(with: error)
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
    
    vCheckbox.rx
      .tapGesture()
      .when(.recognized)
      .map { [unowned self] _ -> Bool in
        var val = try? self.isCheckboxSelected.value()
        val?.toggle()
        return val ?? false
      }
      .bind(to: isCheckboxSelected.asObserver())
      .disposed(by: disposeBag)

    isCheckboxSelected
      .asObservable()
      .bind { [unowned self] isSelected in
        self.ivCheckbox.image = isSelected
          ? Images.checkboxChecked.image
          : Images.checkboxUnchecked.image
      }
      .disposed(by: disposeBag)
    

  }

  func setupViews() {
    
    lbTitle.text = L10n.Login.signupTitle
    
    scrollView.delaysContentTouches = false
    
    vSkipContainer.layer.cornerRadius = 12
    vSkipContainer.layer.masksToBounds = true
    btnSkip.setTitle(L10n.Common.skip.uppercased(), for: .normal)
    
    tfFirstName.attributedPlaceholder = NSAttributedString(string: "First Name", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.6)])
    vFirstnameContainer.layer.cornerRadius = 8

    tfFirstName.autocapitalizationType =  .words
    vFirstnameContainer.layer.masksToBounds = true
    
    tfLastname.attributedPlaceholder = NSAttributedString(string: "Last Name", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.6)])
    vLastnameContainer.layer.cornerRadius = 8
    tfLastname.autocapitalizationType =  .words

    vLastnameContainer.layer.masksToBounds = true
    
    tfPhone.attributedPlaceholder = NSAttributedString(string: "Mobile Number", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.6)])
    vPhoneContainer.layer.cornerRadius = 8
    vPhoneContainer.layer.masksToBounds = true
    phoneTextListener = MaskedTextFieldDelegate()
    phoneTextListener.primaryMaskFormat = L10n.Login.mask
    //tfPhone.delegate = self.phoneTextListener
    
    
    vGender.isHidden = false
    vGender.layer.cornerRadius = 8
    vGender.layer.masksToBounds = true
    lbMaleText.text = L10n.Login.malePlaceholder
    lbFemaleText.text = L10n.Login.femalePlaceholder
    
    btnRegister.setTitle(L10n.Login.signupButtonText, for: .normal)
    btnRegister.setCornerRadius(8)
    
    btnRegister.setBackgroundColor(
      Colors.accentBlue,
      for: .normal,
      animated: true,
      animationDuration: 0.3
    )
    
    btnRegister.setBackgroundColor(
      Colors.accentBlue.withAlphaComponent(0.5),
      for: .highlighted,
      animated: true,
      animationDuration: 0.3
    )
    
    btnRegister.setBackgroundColor(
      Colors.gray2,
      for: .disabled,
      animated: true,
      animationDuration: 0.3
    )
    
    btnLogin.setTitle(L10n.Login.loginButtonText, for: .normal)
    
    setupAgreementLabel()
    
    setupLinkedinButton()
    
    setupGenderSelectionViews()
    
    hideKeyboardWhenTappedAround()
    
    
    
    let skipedStatus = UserDefaults.standard.object(forKey: ContentSettings.Keys.wasSkipAuthorization.rawValue) as? Bool
    guard let skipped_ = skipedStatus else {return}
    if skipped_ == true {
        self.vSkipContainer.isHidden = true
    } 
    
    
    
    
    
    tfPhone.setFlag(key: .RU)
    tfPhone.textColor = UIColor.white.withAlphaComponent(0.6)
    tfPhone.tintColor = UIColor.white.withAlphaComponent(0.6)
    
    
    

 
    
  }
  
  func setupAgreementLabel() {

    
    let formattedText = String.format(strings: [term, policy],
                                        boldFont: UIFont.boldSystemFont(ofSize: 15),
                                        boldColor: Colors.accentBlue,
                                        inString: termText,
                                        font: UIFont.systemFont(ofSize: 15),
                                        color: UIColor.white)
    lbTermsText.attributedText = formattedText
    lbTermsText.numberOfLines = 0
    let tap = UITapGestureRecognizer(target: self, action: #selector(handleTermTapped))
    lbTermsText.addGestureRecognizer(tap)
    lbTermsText.isUserInteractionEnabled = true
    lbTermsText.textAlignment = .left
    
    
    
  }
    
    func checkRange(_ range: NSRange, contain index: Int) -> Bool {
        return index > range.location && index < range.location + range.length
    }
    
    
    @objc func handleTermTapped(gesture: UITapGestureRecognizer) {
        let termString = termText as NSString
        let termRange = termString.range(of: term)
        let policyRange = termString.range(of: policy)

        let tapLocation = gesture.location(in: lbTermsText)
        let index = lbTermsText.indexOfAttributedTextCharacterAtPoint(point: tapLocation)

        if checkRange(termRange, contain: index) == true {
            self.viewModel.termsServiceClicked.onNext(())
            //return
        }

        if checkRange(policyRange, contain: index) {
            self.viewModel.rulesServiceClicked.onNext(())
            //return
        }
    }
    
    
    
  
  func setupLinkedinButton() {
    
    btnSignupWithLinkedIn.isHidden = true
    let image = Images.linkedinImage.image
    let btnTitle = NSMutableAttributedString(
      string: L10n.Login.singUpWithLinkedinButtonText + "  ",
      attributes: [
        NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .semibold),
        NSAttributedString.Key.foregroundColor: UIColor.white
      ]
    )
    let attachment = NSTextAttachment()
    attachment.image = image
    let offsetY: CGFloat = -3
    let newBounds = CGRect(x: 0, y: offsetY, width: image.size.width, height: image.size.height)
    attachment.bounds = newBounds
    let iconString = NSAttributedString(attachment: attachment)
    btnTitle.append(iconString)
    btnSignupWithLinkedIn.setAttributedTitle(btnTitle, for: .normal)
  }
}

// male/female selection
extension SignUpVC {
  func setupGenderSelectionViews() {
    setMaleView(selected: false)
    setFemaleView(selected: false)
    vFemale.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(femaleViewTapped)))
    vMaleContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(maleViewTapped)))
  }
  
  func setMaleView(selected : Bool) {
    lbMaleText.textColor = UIColor.white.withAlphaComponent(selected ? 1.0 : 0.4)
    ivMaleSymbol.tintColor = UIColor.white.withAlphaComponent(selected ? 1.0 : 0.4)
    ivMaleSymbol.image = Images.maleSymbol.image.withRenderingMode(.alwaysTemplate)
  }
  
  func setFemaleView(selected : Bool) {
    lbFemaleText.textColor = UIColor.white.withAlphaComponent(selected ? 1.0 : 0.4)
    ivFemaleSymbol.tintColor = UIColor.white.withAlphaComponent(selected ? 1.0 : 0.4)
    ivFemaleSymbol.image = Images.femaleSymbol.image.withRenderingMode(.alwaysTemplate)
  }
  
  @objc func maleViewTapped() {
    setMaleView(selected: true)
    setFemaleView(selected: false)
    gender.onNext(.male)
  }
  
  @objc func femaleViewTapped() {
    setMaleView(selected: false)
    setFemaleView(selected: true)
    gender.onNext(.female)
  }
}



extension SignUpVC: FPNTextFieldDelegate {
    func fpnDisplayCountryList() {
        print("")
    }
    
    func fpnDidValidatePhoneNumber(textField: FPNTextField, isValid: Bool) {
        
    }
    

    func fpnDidSelectCountry(name: String, dialCode: String, code: String) {
        code_country.onNext(dialCode) // Output "France", "+33", "FR"
    }
}


extension UILabel {
    func indexOfAttributedTextCharacterAtPoint(point: CGPoint) -> Int {
        assert(self.attributedText != nil, "This method is developed for attributed string")
        let textStorage = NSTextStorage(attributedString: self.attributedText!)
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)
        let textContainer = NSTextContainer(size: self.frame.size)
        textContainer.lineFragmentPadding = 0
        textContainer.maximumNumberOfLines = self.numberOfLines
        textContainer.lineBreakMode = self.lineBreakMode
        layoutManager.addTextContainer(textContainer)

        let index = layoutManager.characterIndex(for: point, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        return index
    }
}
