//
//  CheckCodeVC.swift
//  imscored
//
//  Created by Renat Galiamov on 15.05.2020.
//  Copyright © 2020 Renat Galiamov. All rights reserved.
//

import UIKit
import KAPinField
import SimpleButton
import RxSwift
import RxKeyboard

class CheckCodeVC: BaseViewController, KAPinFieldDelegate {
  
  let disposeBag = DisposeBag()
  
  @IBOutlet weak var lbSubtitle: UILabel!
  @IBOutlet weak var btnSkip: UIButton!
  @IBOutlet weak var vSkipContainer: UIView!
  @IBOutlet weak var lbTitle: UILabel!
  @IBOutlet weak var pinField: KAPinField!
  @IBOutlet weak var btnContinue: SimpleButton!
  @IBOutlet weak var btnRepeat: UIButton!
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var back: UIButton!
  @IBOutlet weak var back_view: UIView!
    
    var viewModel: CheckCodeViewModel!
  var code = PublishSubject<String>()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let gesture = UITapGestureRecognizer(target: self, action:  #selector (handleGesture))
    self.back_view.addGestureRecognizer(gesture)
    self.back.addGestureRecognizer(gesture)
    setupViews()
    setupViewModelInput()
    setupViewModelOutput()
    addGesture()
  }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //self.hideKeyboardWhenTappedAround()
    }
    
    @IBAction func clicked(_ sender: Any) {
         self.viewModel.back()
    }
    
    func addGesture() {
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeLeft.direction = .right
        self.view.addGestureRecognizer(swipeLeft)
  }
  
    
    @objc func handleGesture() {
        self.viewModel.back()
    }
    

    @IBAction func back__(_ sender: Any) {
        print("backed backed ")
        self.viewModel.back()
    }
    
 
  func setupViewModelInput() {
    let bindings = CheckCodeViewModelBindings(
      didPressContinue: btnContinue.rx.tap.asDriver(),
      didPressRepeat: btnRepeat.rx.tap.asDriver(),
      didPressSkipAuthorization: btnSkip.rx.tap.asDriver(),
      code: code.asDriverOnErrorJustComplete(),
      backTapped:back.rx.tap.asDriver())
    
    viewModel.configure(with: bindings)
  }
  
  func setupViewModelOutput() {
    

    viewModel.canContinue.asObservable().bind(to: btnContinue.rx.isEnabled).disposed(by: disposeBag)
    
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
        print("EROOR OCCURENDe \(error)")
        self?.hideActivityHUD()
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
    setupPinField()
    isHideNavbar = true
    
    lbTitle.text = L10n.Login.checkCodeTitle
    lbSubtitle.text = L10n.Login.checkCodeDescription
    
    scrollView.delaysContentTouches = false
    
    vSkipContainer.layer.cornerRadius = 12
    vSkipContainer.layer.masksToBounds = true
    btnSkip.setTitle(L10n.Common.skip.uppercased(), for: .normal)
    
    btnContinue.setCornerRadius(8)
    btnContinue.setTitle(L10n.Common.continue, for: .normal)
    btnContinue.setBackgroundColor(
      Colors.accentBlue,
      for: .normal,
      animated: true,
      animationDuration: 0.3
    )
    
    btnContinue.setBackgroundColor(
      Colors.accentBlue.withAlphaComponent(0.5),
      for: .highlighted,
      animated: true,
      animationDuration: 0.3
    )
    
    btnContinue.setBackgroundColor(
      Colors.gray2,
      for: .disabled,
      animated: true,
      animationDuration: 0.3
    )

    
    
    btnRepeat.setTitle(L10n.Login.repeatButtonTitle, for: .normal)
        
    hideKeyboardWhenTappedAround()
    
    
    let skipedStatus = UserDefaults.standard.object(forKey: ContentSettings.Keys.wasSkipAuthorization.rawValue) as? Bool
    guard let skipped_ = skipedStatus else {return}
    if skipped_ == true {
        self.vSkipContainer.isHidden = true
    }
    
  }
  
  func setupPinField() {
    pinField.properties.delegate = self
    pinField.properties.token = "_"
    pinField.properties.animateFocus = false
    pinField.properties.numberOfCharacters = 6
    pinField.keyboardType = .numberPad
    pinField.appearance.tokenColor = UIColor.white.withAlphaComponent(0.4)
    pinField.appearance.tokenFocusColor = UIColor.white.withAlphaComponent(0.4)
    pinField.appearance.textColor = UIColor.white.withAlphaComponent(0.8)
    pinField.appearance.font = .menlo(20)
    pinField.appearance.kerning = 40
    pinField.appearance.backOffset = 10
    pinField.appearance.backColor = UIColor.black.withAlphaComponent(0.6)
    pinField.appearance.backFocusColor = UIColor.black.withAlphaComponent(0.6)
    pinField.appearance.backActiveColor =  UIColor.black.withAlphaComponent(0.6)
    
    pinField.appearance.backBorderWidth = 0
    pinField.appearance.backBorderColor = UIColor.clear
    pinField.appearance.backCornerRadius = 4
    
    pinField.appearance.backBorderFocusColor = UIColor.clear
    
    pinField.appearance.backBorderActiveColor = UIColor.clear
    pinField.appearance.backRounded = false
  }
  
  func pinField(_ field: KAPinField, didFinishWith code: String) {
      checkCodeInput()
  }
  
  func checkCodeInput() {
      let currentStr = pinField.text ?? ""
      if currentStr.count == Constants.smsConfirmationCodeLength {
          view.endEditing(true)
          code.onNext(currentStr)
      }
  }
}
