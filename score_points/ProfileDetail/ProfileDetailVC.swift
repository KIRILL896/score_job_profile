

import UIKit
import RxSwift
import RxDataSources
import RxCocoa
import RxGesture
import Hero
import AudioToolbox
extension ProfileModule {
  class Detail {}
}

extension ProfileModule.Detail {
  class ViewController: BaseViewController {
    // MARK: - subviews
    let statisticView = Statistic()
    let selfScoring = Components.ScoreButton(text: L10n.Profile.selfScoring)
    let logOut = Components.color_button(color:UIColor.red, text:"Log Out")
    
    let linkedin = makeLinkdnLink()
    let linkedinEnabled = makeLinkdnEnabling()
    
    let traitsVisibility = makeTraitsVisibility()
    
    let invite = makeInviteFriends()
    let history = makeScoringHistory()
    let traits = makeVisibleTraits()
    let qr = makeQrCode()
    let delete = makeDeleteProfile()

    let scoringHistory = makeQrScoringHistory()
    let Myprofile = makeAccount()
    let displayExternal = makeDisplayOnEnternalPage()
    
    
    let profileView: ProfileView = {
      let view = ProfileView()
        if #available(iOS 13.0, *) {
            let smallConfiguration = UIImage.SymbolConfiguration(scale: .small)
            let smallSymbolImage = UIImage(systemName: "square.and.pencil", withConfiguration: smallConfiguration)
            view.actionButton.setImage(smallSymbolImage, for: .normal)
        } else {
            view.actionButton.setImage(UIImage(named: "Edit"), for: .normal)

            // Fallback on earlier versions
        }
      view.actionButton.setImage(UIImage(named: "Edit"), for: .normal)
      view.actionButton.isHidden = false
      view.actionButton.setTitleColor(Colors.accentBlue, for: .normal)
      return view
    }()
    
    // MARK: - data && rx
    let disposeBag = DisposeBag()
    var viewModel: ViewModel!
    
    let confirmChanges = PublishSubject<Void>()
    let deleteProfile = PublishSubject<Void>()
    let logOutProfile = PublishSubject<Void>()
    

    let historySubj = BehaviorSubject<Bool>(value: false)
    let traitsSubj = BehaviorSubject<Bool>(value: false)
    let linkedinSubj = BehaviorSubject<Bool>(value: false)
    let trairsVisibilitySubj = BehaviorSubject<String>(value: "")
    let displayOnWebPageSubj = BehaviorSubject<String>(value: "")
    
    let traitsObservableText:Observable<String> = Observable<String>.just("")
    
    

    
    // MARK: - lifecycle
    override func viewDidLoad() {
      super.viewDidLoad()
      addNotificationButton()
      navigationItem.title = L10n.Profile.title
      setupConstraints()
      setupViewModelInput()
      setupViewModelOutput()
      statisticView.hero.id = "statisticView"
      selfScoring.hero.id = "selfScoring"
    }
        

    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //self.viewModel.request_double_services()
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let navbar = navigationController?.navigationBar {
           ScoreCounter.remove(in: navbar)
           ScoreName.remove(in: navbar)
           ScoreAvatar.remove(in: navbar)

         }
        self.showNotificationButton()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
      confirmChanges.onNext(())
    }
  }
}

// MARK: - Data
extension ProfileModule.Detail.ViewController {
  func setupViewModelInput() {
    linkedinEnabled.1.rx.isOn.bind(to: self.linkedinSubj).disposed(by: disposeBag)
    history.1.rx.isOn.bind(to: self.historySubj).disposed(by: disposeBag)
    traits.1.rx.isOn.bind(to: self.traitsSubj).disposed(by: disposeBag)
    
    self.trairsVisibilitySubj.bind(to: self.traitsVisibility.1.rx.text).disposed(by: disposeBag)
    
    self.displayOnWebPageSubj.bind(to: self.displayExternal.1.rx.text).disposed(by: disposeBag)
    
    
    let bindings = ProfileModule.Detail.ViewModel.Bindings(
      redoAction: profileView.actionButton.rx.tap.asDriver(),
      seeStory: statisticView.seeAll.rx.tap.asDriver(),
      selfScoring: selfScoring.rx.tap.asDriver() ,
      deleteProfile: deleteProfile.asDriverOnErrorJustComplete(),
      goToQr: qr.rx
        .tapGesture()
        .when(.recognized)
        .mapToVoid()
        .asDriverOnErrorJustComplete(),
      enableLinkdn: linkedinSubj.asDriverOnErrorJustComplete(),
      givenScoredHistory: historySubj.asDriverOnErrorJustComplete(),
      seeDetailedScore: traitsSubj.asDriverOnErrorJustComplete(),
      confirmChanges: confirmChanges.asDriverOnErrorJustComplete(),
      traitsVisibility: trairsVisibilitySubj.asDriverOnErrorJustComplete(),
      displayWebPage: displayOnWebPageSubj.asDriverOnErrorJustComplete(),
      logOutProfile: logOutProfile.asDriverOnErrorJustComplete(),
      scoringHistory: scoringHistory.rx.tapGesture().when(.recognized).mapToVoid().asDriverOnErrorJustComplete(),
      myProfile:  Myprofile.rx.tapGesture().when(.recognized).mapToVoid().asDriverOnErrorJustComplete()
    )
    viewModel.configure(with: bindings)
    
    
    
    
    
    self.selfScoring.rx.tapGesture().when(.recognized).asObservable().bind { [weak self] _ in
        self?.moreUserTapped()
        
    }.disposed(by: disposeBag)
    
    
  }
  
  func setupViewModelOutput() {
    viewModel.loading.drive(onNext : { [weak self] loading in
      DispatchQueue.main.async {
        if loading {
          self?.showActivityHUD()
        } else {
          self?.hideActivityHUD()
        }
      }
    }).disposed(by: disposeBag)

    viewModel.errorOccured.drive(onNext : { [weak self] error in
      DispatchQueue.main.async {
        self?.showErrorToast(with: error)
      }
    }).disposed(by: disposeBag)

    viewModel.user.bind { [unowned self] user in
      self.profileView.setup(user: user)
      self.linkedin.1.text = user.linkedin ?? "No Linkedin Added"//L10n.Profile.emptyLinkedin
      self.linkedinEnabled.1.isOn = user.hiddenFields.contains("linkedin")
      self.history.1.isOn = user.rateHistory
      self.traits.1.isOn = user.visibleTraits
      self.linkedinSubj.onNext(self.linkedinEnabled.1.isOn)
      self.historySubj.onNext(self.history.1.isOn)
      self.traitsSubj.onNext(self.traits.1.isOn)
      //let rating = user.rating()
      self.traitsVisibility.1.text = user.get_traits_visibility_description()
        
      self.trairsVisibilitySubj.onNext(user.get_traits_visibility_description())
      if user.proStatus == false {
          self.displayExternal.0.isHidden = true
          self.linkedin.0.isHidden = true
      } else {
    
          self.linkedin.1.text = "https://imscored.com/user/" + user.userId
          self.linkedin.0.isHidden = false
          self.displayExternal.0.isHidden = false
          self.displayExternal.1.text = user.get_display_page_description()
          
      }
        
      let scoreValue = user.scoreValue == nil ? String(0.0) : String(format: "%.1f", user.scoreValue!)//user.scoreValue!.string(fractionDigits: 1)//String(user.scoreValue!)
      let scoreCount = user.scoreCount == nil ? 0 : Int(user.scoreCount!)
        
      print("SCORE VALUE \(scoreValue) \(scoreCount) \(self.statisticView)")
        
        
      self.statisticView.setup(statNum: scoreCount, rate: scoreValue)
        
      //self.statisticView.points.text = L10n.OtherPerson.points(rating.string(fractionDigits: 1))
    }
    .disposed(by: disposeBag)
    
    
    logOut.rx.tapGesture().when(.recognized).mapToVoid().observeOn(MainScheduler.instance).bind { [unowned self] _ in
        let confirm = UIAlertAction(title: "Log Out", style: .default) { [weak self] _ in
            self?.logOutProfile.onNext(())
        }
        let cancel = UIAlertAction(title: L10n.Common.cancel, style: .cancel, handler: nil)
        let alert = UIAlertController.init(title: "Log Out ?", message: "Do you really want to log out ?", preferredStyle: .alert)
        alert.addAction(confirm)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }.disposed(by: disposeBag)
    
    
    delete.rx
      .tapGesture()
      .when(.recognized)
      .mapToVoid()
      .observeOn(MainScheduler.instance)
      .bind { [unowned self] _ in
        let confirm = UIAlertAction(title: L10n.Common.delete, style: .default) { [weak self] _ in
          self?.deleteProfile.onNext(())
        }
        let cancel = UIAlertAction(title: L10n.Common.cancel, style: .cancel, handler: nil)
        let alert = UIAlertController.init(title: L10n.Profile.deleteTitle, message: L10n.Profile.deleteDescription, preferredStyle: .alert)
        alert.addAction(confirm)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
      }
      .disposed(by: disposeBag)
    
    traitsVisibility.0.rx.tapGesture().when(.recognized).mapToVoid().bind { [unowned self] _ in
        let transition = PanelTransition()
        let child = ChildViewController()
        child.get_value = self.traitsVisibility.1.text!
        child.transitioningDelegate = transition
        child.modalPresentationStyle = .custom
        self.present(child, animated: true)
        child.items.asObservable().subscribe(onNext:{[unowned self] value in
            let values_text = value.filter{$0.selected == true}
            if values_text.count > 0 {
                self.trairsVisibilitySubj.onNext(values_text[0].name)
                self.traitsVisibility.1.text = values_text[0].name
            }
        }).disposed(by: self.disposeBag)
    }.disposed(by: disposeBag)
    
    displayExternal.0.rx.tapGesture().when(.recognized).mapToVoid().bind { [unowned self] _ in
        
        let transition = PanelTransition()
        let child = DisplayOnWebPageVC()
        child.get_value = self.displayExternal.1.text!
        child.transitioningDelegate = transition
        child.modalPresentationStyle = .custom
        self.present(child, animated: true)
        
        child.items.asObservable().subscribe(onNext:{[unowned self] value in
            
            print("value \(value)")
            
            let values_text = value.filter{$0.selected == true}
            if values_text.count > 0 {
                self.displayOnWebPageSubj.onNext(values_text[0].name)
                self.displayExternal.1.text = values_text[0].name
            }
            
            self.confirmChanges.onNext(())
            
            
        }).disposed(by: self.disposeBag)
        
    }.disposed(by: disposeBag)
    

    
    invite.rx
      .tapGesture()
      .when(.recognized)
      .mapToVoid()
      .bind { [unowned self] _ in
        let text = L10n.sharing

        let activityViewController = UIActivityViewController(
          activityItems: [text],
          applicationActivities: nil
        )

        activityViewController.excludedActivityTypes = [
          .addToReadingList,
          .assignToContact,
          .saveToCameraRoll
        ]

        self.present(activityViewController, animated: true, completion: nil)
      }
      .disposed(by: disposeBag)
    
    linkedin.0.rx
      .tapGesture()
      .when(.recognized)
      .mapToVoid()
      .bind { [unowned self] _ in
        if let text = self.linkedin.1.text {
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            Vibration.success.vibrate()
            UIPasteboard.general.string = text

        }
      }
      .disposed(by: disposeBag)
    
    
    /*
    viewModel
      .statisticData
      .bind { [unowned self] data in
        print("GET STATISTICS DATA OF \(data)")
        //self.profileView.rating.text = "rating " + String(data.1)
        let formatted = String(format: "%.1f", data.1)
        self.profileView.points.text =  "IM " + formatted + "・" + String(data.0)
        self.statisticView.setup(statNum: Int(data.0), rate: data.1)
      }
      .disposed(by: disposeBag) */

    viewModel
      .isSelfScoringVisible
      .asObservable()
      .bind { isVisible in
        self.selfScoring.isHidden = !isVisible
      }
      .disposed(by: disposeBag)
  }
}

// MARK: - Constraints
extension ProfileModule.Detail.ViewController {
    
    func moreUserTapped() {

      let alertVC = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
      let scoreMe = UIAlertAction(
        title: "Social Scoring",
        style: .default) { [weak self] _ in
        self?.viewModel.scroingTapped.onNext("social")
          //self?.scoreMeUser.onNext(user)
      }
      
      let score = UIAlertAction(
        title: "PRO Scoring",
        style: .default) { [weak self] _ in
        self?.viewModel.scroingTapped.onNext("pro")
          //self?.scoreUser.onNext(user)
      }
      let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
      alertVC.addAction(scoreMe)
      alertVC.addAction(score)
      alertVC.addAction(cancel)
      self.present(alertVC, animated: true, completion: nil)
    }
    
    
    
  func setupConstraints() {
    selfScoring.isHidden = true

    view.backgroundColor = .white
    
    let scrollView = UIScrollView()
    scrollView.autoresizingMask = .flexibleHeight
    
    view.addSubview(scrollView)
    scrollView.makeAnchors { make in
      make.top(equalTo: view.safeTop)
      make.bottom(equalTo: view.safeBottom)
      make.leading(equalTo: view.leading)
      make.trailing(equalTo: view.trailing)
    }
    scrollView.backgroundColor = Colors.screenBg
    
    let cellsStack = UIStackView(arrangedSubviews: [statisticView, selfScoring, history.0, traitsVisibility.0, scoringHistory, Myprofile, linkedin.0, displayExternal.0])
    
/*    let cellsStack = UIStackView(arrangedSubviews: [statisticView, selfScoring, logOut, linkedin.0, /*linkedinEnabled.0,*/ /*invite,*/ history.0, traitsVisibility.0/*, traits.0, qr, delete*/, scoringHistory, Myprofile])*/

    cellsStack.axis = .vertical
    cellsStack.alignment = .fill
    cellsStack.distribution = .equalSpacing
    cellsStack.spacing = 16
    let cellsView = UIView()
    cellsView.backgroundColor = Colors.screenBg
    cellsStack.full(in: cellsView, horOffset: 16, verOffset: 16)
        
    let stackView = UIStackView(arrangedSubviews: [profileView, cellsView])
    stackView.axis = .vertical
    stackView.alignment = .fill
    stackView.distribution = .equalSpacing
    stackView.spacing = 0
    scrollView.addSubview(stackView)
    stackView.makeAnchors{ make in
      make.top(equalTo: scrollView.top)
      make.bottom(lessThan: scrollView.bottom)
      make.leading(equalTo: scrollView.leading)
      make.trailing(equalTo: scrollView.trailing)
      make.width(equalTo: scrollView.width)
    }
  }
}

// MARK: - helpers
extension ProfileModule.Detail.ViewController {
    static func makeCellCopy() -> (UIView, UILabel) {
      let view = UIView()
      view.hero.modifiers = [.translate(x: 0, y: 500, z: 0)]
      view.backgroundColor = .white
      view.round()
      let label = UILabel()
      label.setContentHuggingPriority(.defaultLow, for: .horizontal)
      view.addSubview(label)
      label.makeAnchors { make in
        make.leading(equalTo: view.leading, constant: 16)
        make.top(greaterThan: view.top, constant: 8)
        make.centerY(equalTo: view.centerY)
        make.trailing(equalTo: view.trailing, constant:-56)
      }
      label.textColor = .black
      label.font = .systemFont(ofSize: 17)
      label.numberOfLines = 0
      return (view, label)
    }
    
    
  static func makeCell() -> (UIView, UILabel) {
    let view = UIView()
    view.hero.modifiers = [.translate(x: 0, y: 500, z: 0)]
    view.backgroundColor = .white
    view.round()
    let label = UILabel()
    label.setContentHuggingPriority(.defaultLow, for: .horizontal)
    view.addSubview(label)
    label.makeAnchors { make in
      make.leading(equalTo: view.leading, constant: 16)
      make.top(greaterThan: view.top, constant: 8)
      make.centerY(equalTo: view.centerY)

    }
    label.textColor = .black
    label.font = .systemFont(ofSize: 17)
    label.numberOfLines = 0
    return (view, label)
  }
    
    static func makeCell_() -> (UIView, UILabel, UILabel) {
      let view = UIView()
      view.hero.modifiers = [.translate(x: 0, y: 500, z: 0)]
      view.backgroundColor = .white
      view.round()
      let label = UILabel()
      label.setContentHuggingPriority(.defaultLow, for: .horizontal)
      view.addSubview(label)
      label.makeAnchors { make in
        make.leading(equalTo: view.leading, constant: 16)
        make.top(equalTo: view.top, constant: 8)
        //make.centerY(equalTo: view.centerY)
      }
      label.textColor = .black
      label.font = .systemFont(ofSize: 17)
      label.numberOfLines = 0
        
      let label2 = UILabel()
      //label2.setContentHuggingPriority(.defaultLow, for: .horizontal)
      view.addSubview(label2)
      label2.makeAnchors { make in
        make.leading(equalTo: view.leading, constant: 16)
        make.top(equalTo: label.bottom, constant: 4)
        make.bottom(equalTo: view.bottom, constant: -8)
      }
      label2.textColor = Colors.subtitleText
      label2.font = .systemFont(ofSize: 14)
      label2.numberOfLines = 0
        
        
      return (view, label, label2)
    }
  
    
  static func makeDisplayOnEnternalPage() -> (UIView, UILabel) {
    let cell = makeCell_()
    cell.1.text = "Display on My External Web Page"//L10n.Profile.qr
    cell.2.text = "Display on My External Web Page"
    let icon = UIImageView(image: Images.arrow.image)
    cell.0.addSubview(icon)
    icon.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    icon.makeAnchors { make in
      make.height(13)
      make.width(8)
      make.centerY(equalTo: cell.0.centerY)
      make.trailing(equalTo: cell.0.trailing, constant: -16)
      make.leading(equalTo: cell.1.trailing, constant: 16)
    }
    
    return (cell.0, cell.2)
  }
    
    
  static func makeLinkdnLink() -> (UIView, UILabel) {
    let cell = makeCellCopy()
    cell.1.text = L10n.Common.loading
    
    let icon = UIImageView(image: Images.copy.image)
    cell.0.addSubview(icon)
    icon.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    icon.makeAnchors { make in
      make.centerY(equalTo: cell.0.centerY)
      make.trailing(equalTo: cell.0.trailing, constant: -16)
      make.leading(equalTo: cell.1.trailing, constant: 16)
    }
    
    return cell
  }
  
    

  static func makeLinkdnEnabling() -> (UIView, UISwitch) {
    let cell = makeCell()
    cell.1.text = "Link Linkedin"//L10n.Profile.linkLinkedin
    let swit = UISwitch()
    cell.0.addSubview(swit)
    swit.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    swit.makeAnchors { make in
      make.centerY(equalTo: cell.0.centerY)
      make.trailing(equalTo: cell.0.trailing, constant: -16)
      make.leading(equalTo: cell.1.trailing, constant: 16)
    }
    
    return (cell.0, swit)
  }

    
    static func makeTraitsVisibility() -> (UIView, UILabel){
        let cell = makeCell()
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        label.textColor = Colors.subtitleText
        cell.0.addSubview(label)
        
        let icon = UIImageView(image: Images.arrow.image)
        cell.0.addSubview(icon)
        icon.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        icon.makeAnchors { make in
             make.height(13)
             make.width(8)
             make.centerY(equalTo: cell.0.centerY)
             make.trailing(equalTo: label.trailing, constant: 14)
             make.leading(equalTo: label.trailing, constant: 16)
        }
        
        
        
        label.makeAnchors { make in
           make.centerY(equalTo: cell.0.centerY)
           make.trailing(equalTo: cell.0.trailing, constant: -38)
           make.leading(equalTo: cell.1.trailing, constant: 16)
        }
        cell.1.text = "Display Detailed Score"
        return (cell.0, label)
    }
    
    
    
    
  static func makeInviteFriends() -> UIView {
    let cell = makeCell()
    cell.1.text = "To Invite a Friend"//L10n.Profile.invite
    
    let img = Images.plus.image.withRenderingMode(.alwaysTemplate)
    let icon = UIImageView(image: img)
    icon.tintColor = Colors.accentBlue

    cell.0.addSubview(icon)
    icon.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    icon.makeAnchors { make in
      make.centerY(equalTo: cell.0.centerY)
      make.trailing(equalTo: cell.0.trailing, constant: -16)
      make.leading(equalTo: cell.1.trailing, constant: 16)
    }
    
    return cell.0
  }

  static func makeScoringHistory() -> (UIView, UISwitch) {
    let cell = makeCell()
    cell.1.text = "Outgoing Scoring History "//L10n.Profile.historyEnable
    
    let swit = UISwitch()
    let save = UILabel()
    save.text = "Save"//L10n.Common.save
    save.font = .systemFont(ofSize: 17)
    save.textColor = Colors.subtitleText
    
    cell.0.addSubview(swit)
    cell.0.addSubview(save)
    save.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    swit.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    swit.makeAnchors { make in
      make.centerY(equalTo: cell.0.centerY)
      make.trailing(equalTo: cell.0.trailing, constant: -16)
    }
    
    save.makeAnchors { make in
      make.centerY(equalTo: cell.0.centerY)
      make.trailing(equalTo: swit.leading, constant: -16)
      make.leading(equalTo: cell.1.trailing, constant: 16)
    }
    
    return (cell.0, swit)
  }

  static func makeVisibleTraits() -> (UIView, UISwitch) {
    let cell = makeCell()
    cell.1.text = "Display Detailed Score"//L10n.Profile.visibleTraits
    let swit = UISwitch()
    cell.0.addSubview(swit)
    swit.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    swit.makeAnchors { make in
      make.centerY(equalTo: cell.0.centerY)
      make.trailing(equalTo: cell.0.trailing, constant: -16)
      make.leading(equalTo: cell.1.trailing, constant: 16)
    }
    
    return (cell.0, swit)
  }

  static func makeDeleteProfile() -> UIView {
    let cell = makeCell()
    cell.1.text = L10n.Profile.delete
    cell.1.textColor = Colors.desctructive
    
    cell.1.makeAnchors { make in
      make.trailing(equalTo: cell.0.trailing, constant: -16)
    }
    
    return cell.0
  }
  
    static func makeQrScoringHistory() -> UIView {
      let cell = makeCell()
      cell.1.text = "Scoring History"//L10n.Profile.qr
      
      let icon = UIImageView(image: Images.arrow.image)
      cell.0.addSubview(icon)
      icon.setContentHuggingPriority(.defaultHigh, for: .horizontal)
      icon.makeAnchors { make in
        make.height(13)
        make.width(8)
        make.centerY(equalTo: cell.0.centerY)
        make.trailing(equalTo: cell.0.trailing, constant: -16)
        make.leading(equalTo: cell.1.trailing, constant: 16)
      }
      
      return cell.0
    }
    
    static func makeAccount() -> UIView {
      let cell = makeCell()
      cell.1.text = "My Account"//L10n.Profile.qr
      
      let icon = UIImageView(image: Images.arrow.image)
      cell.0.addSubview(icon)
      icon.setContentHuggingPriority(.defaultHigh, for: .horizontal)
      icon.makeAnchors { make in
        make.height(13)
        make.width(8)
        make.centerY(equalTo: cell.0.centerY)
        make.trailing(equalTo: cell.0.trailing, constant: -16)
        make.leading(equalTo: cell.1.trailing, constant: 16)
      }
      
      return cell.0
    }
    
    
    
    
  static func makeQrCode() -> UIView {
    let cell = makeCell()
    cell.1.text = "QR-Code"//L10n.Profile.qr
    
    let icon = UIImageView(image: Images.arrow.image)
    cell.0.addSubview(icon)
    icon.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    icon.makeAnchors { make in
      make.height(13)
      make.width(8)
      make.centerY(equalTo: cell.0.centerY)
      make.trailing(equalTo: cell.0.trailing, constant: -16)
      make.leading(equalTo: cell.1.trailing, constant: 16)
    }
    
    return cell.0
  }
}


enum Vibration {
        case error
        case success
        case warning
        case light
        case medium
        case heavy
        @available(iOS 13.0, *)
        case soft
        @available(iOS 13.0, *)
        case rigid
        case selection
        case oldSchool

        public func vibrate() {
            switch self {
            case .error:
                UINotificationFeedbackGenerator().notificationOccurred(.error)
            case .success:
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            case .warning:
                UINotificationFeedbackGenerator().notificationOccurred(.warning)
            case .light:
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            case .medium:
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            case .heavy:
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            case .soft:
                if #available(iOS 13.0, *) {
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                }
            case .rigid:
                if #available(iOS 13.0, *) {
                    UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                }
            case .selection:
                UISelectionFeedbackGenerator().selectionChanged()
            case .oldSchool:
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            }
        }
    }
