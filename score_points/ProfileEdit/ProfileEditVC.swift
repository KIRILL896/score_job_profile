

import UIKit
import ObjectiveC
import RxSwift
import RxDataSources
import RxCocoa
import RxGesture
import CropViewController
import FlagPhoneNumber


extension ProfileModule {
  class Edit {}
}


class CustomTextField: UITextField {

    let padding = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)

    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
}


extension ProfileModule.Edit {
  class ViewController: BaseViewController {
    // MARK: - subviews
    let save = UIBarButtonItem(barButtonSystemItem: .save, target: nil, action: nil)
    let close = UIBarButtonItem(image: Images.close.image, style: .plain, target: nil, action: nil)
    var scrollview:UIScrollView!
    
    
    var cropViewController:CropViewController? = nil
    
    let avatarView: UIImageView = {
      let view = UIImageView()
      view.height(90).isActive = true
      view.width(90).isActive = true
      view.round(radius: 45)
      view.image = Images.camera.image
      return view
    }()
    
    //let statisticView = ProfileModule.Detail.Statistic()
    //let selfScoring = Components.button(text: L10n.Profile.selfScoring)

    let gender = SwitcherButton(
      firstTitle: "  \(L10n.Login.malePlaceholder)",
      firstImg: Images.maleSymbol.image,
      secondTitle: "  \(L10n.Login.femalePlaceholder)",
      secongImg: Images.femaleSymbol.image)
    
    let occupancy = SwitcherButton(
      firstTitle: L10n.Scoring.Occupancy.team,
      secondTitle: L10n.Scoring.Occupancy.selfEmployed
    )
    
    
    
    

    
    let bio: UITextView = {
      let view = UITextView()
      view.font = .systemFont(ofSize: 17)
      view.textColor = .black
        //
      view.text = L10n.OtherPerson.bio
      view.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
      view.isScrollEnabled = false
      view.round()
      view.isEditable = true
      view.isSelectable = true
      return view
    }()
    
    
    var phoneNumberTextField:FPNTextField!

    
    let bio_off: UITextField = {
       let view = CustomTextField()
       view.backgroundColor = UIColor.white
       view.round()
       //view.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
       view.placeholder = "Bio"
       view.font = .systemFont(ofSize: 17)
       view.textColor = .black
       view.textAlignment = .left
       return view
    }()
    
    
    let table: UITableView = {
      let table = UITableView()
      table.isScrollEnabled = false
      table.round()
      table.tableFooterView = UIView()
      table.backgroundColor = .white
      table.register(EditTextfieldCell.self, forCellReuseIdentifier: EditTextfieldCell.reuseIdentifier)
      table.register(EditSwitchCell.self, forCellReuseIdentifier: EditSwitchCell.reuseIdentifier)
      table.register(EditSelectCell.self, forCellReuseIdentifier: EditSelectCell.reuseIdentifier)
      table.register(EditPhoneCell.self, forCellReuseIdentifier: EditPhoneCell.reuseIdentifier)
      return table
    }()
        
    var tableConstraint: NSLayoutConstraint!
    var visibleCount = 0

    var picker: ImagePicker?

    // MARK: - data && rx
    let disposeBag = DisposeBag()
    var viewModel: ViewModel!
    let modelDeleted = PublishSubject<ProfileEditCellModel>()
    let modelSelected = PublishSubject<ProfileEditCellModel>()
    let avatarPicker = PublishSubject<UIImage>()

    // MARK: - lifecycle
    override func viewDidLoad() {
      super.viewDidLoad()
      setupConstraints()
      setupViewModelInput()
      setupViewModelOutput()
      
      //statisticView.hero.id = "statisticView"
      //selfScoring.hero.id = "selfScoring"
        
      NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
      NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
      
    
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      self.hideNotificationButton()
      self.navigationController?.hero.isEnabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
      super.viewDidDisappear(animated)
      self.showNotificationButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //self.showNotificationButton()
    }
    
    
    
    @objc func keyboardWillShow(notification: NSNotification) {
       guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
       else {
         // if keyboard size is not available for some reason, dont do anything
         return
       }

        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize.height , right: 0.0)
        self.scrollview.contentInset = contentInsets
        self.scrollview.scrollIndicatorInsets = contentInsets
     }

     @objc func keyboardWillHide(notification: NSNotification) {
       let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
           
       
       // reset back the content inset to zero after keyboard is gone
        self.scrollview.contentInset = contentInsets
        self.scrollview.scrollIndicatorInsets = contentInsets
     }
    
    
    
    
  }
}

// MARK: - Data
extension ProfileModule.Edit.ViewController:UITextFieldDelegate {
    

    
    
  func setupViewModelInput() {
    
    
    self.bio_off.text = viewModel.bioText

    
    let bindings = ProfileModule.Edit.ViewModel.Bindings(
      save: save.rx.tap.asDriver(),
      isMale: gender.isFirstSelectedObs.asDriverOnErrorJustComplete(),
      isTeamMember: occupancy.isFirstSelectedObs.asDriverOnErrorJustComplete(),
      bio: bio_off.rx.text.orEmpty.asDriver(),
      modelDeleted: modelDeleted.asDriverOnErrorJustComplete(),
      image: avatarPicker.asDriverOnErrorJustComplete(),
      selected: modelSelected.asDriverOnErrorJustComplete(),
      close: self.close.rx.tap.mapToVoid().asDriverOnErrorJustComplete()
    )
    viewModel.configure(with: bindings)
  }
    
    

    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        
        //let desiredPosition = textField.beginningOfDocument
        //textField.selectedTextRange = textField.textRangeFromPosition(desiredPosition, toPosition: desiredPosition)
        //let position = textField.position(from: textField.beginningOfDocument, offset: 5)!
        textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.beginningOfDocument)
        
        
        
        //let endPosition = textField.endOfDocument
        //textField.selectedTextRange = textField.textRange(from: endPosition, to: endPosition)
    }
    
    /*
   func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
       guard let textFieldText = textField.text,
           let rangeOfTextToReplace = Range(range, in: textFieldText) else {
               return false
       }
       let substringToReplace = textFieldText[rangeOfTextToReplace]
       let count = textFieldText.count - substringToReplace.count + string.count
       return count <= 10
  } */
    
    
    @objc func myTargetFunction(textField: UITextField) {
        print("myTargetFunction")
    }
    
  
  func setupViewModelOutput() {
    
    
    
    
    
    
    let datasource = RxTableViewSectionedAnimatedDataSource
      <ProfileEditSectionModel>(
        configureCell: { [self] _, table, indexPath, item in
          let cell: UITableViewCell
          switch item.type {
          case .phone:
            let phoneModel = item as! PhoneEditCellModel
            let phoneCell = table.dequequeCell(EditPhoneCell.self, for: indexPath)
            phoneCell.setup(phoneModel)
            cell = phoneCell
          case .select:
            let selectModel = item as! SelectEditCellModel
            let selectCell = table.dequequeCell(EditSelectCell.self, for: indexPath)
            selectCell.setup(selectModel, country:self.phoneNumberTextField.selectedCountry)
            cell = selectCell
          case .switcher:
            let switchModel = item as! SwitchEditCellModel
            let switchCell = table.dequequeCell(EditSwitchCell.self, for: indexPath)
            switchCell.setup(switchModel)
            cell = switchCell
          case .textfield:
            let tfModel = item as! TextfieldEditCellModel
            let tfCell = table.dequequeCell(EditTextfieldCell.self, for: indexPath)
            
            
            tfCell.tf.delegate = self

            tfCell.setup(tfModel)
           // tfCell.tf.addTarget(self, action: #selector(self.myTargetFunction), for: .touchDown)

            //if let _ = tfModel.max_count as? Int {
            
        
            cell = tfCell
          }
          return cell
        }, canEditRowAtIndexPath: { section, indexPath in
          let sectionModel = section.sectionModels[indexPath.section]
          let model = sectionModel.items[indexPath.row]
          return model.hideIdentifier != nil
        })

    datasource.animationConfiguration = .init(
      insertAnimation: .none,
      reloadAnimation: .none,
      deleteAnimation: .none
    )

    
    
    
    
    viewModel
      .redoUser
      .asObservable()
      .bind { [unowned self] ud in
        self.avatarView.set(url: ud.selfie)
        
      }
      .disposed(by: disposeBag) 
   
    
    viewModel.tableElems
      .map { items in
        return [ProfileEditSectionModel(items: items, id: "ProfileEditSectionModel")]
      }
      .bind(to: table.rx.items(dataSource: datasource))
      .disposed(by: disposeBag)
    
    viewModel
      .tableElems
      .delay(.milliseconds(1), scheduler: MainScheduler.instance)
      .bind { [unowned self] elems in
        self.visibleCount = elems
          .filter { $0.isShowing }
          .count

        self.tableConstraint.constant = self.table.contentSize.height
        UIView.animate(withDuration: 0.25) {
          self.table.layoutIfNeeded()
        }
      }
      .disposed(by: disposeBag)


    close.rx.tap.bind { [unowned self] _ in
      self.dismiss(animated: true, completion: nil)
    }
    .disposed(by: disposeBag)

    gender.select(isFirst: viewModel.initialIsMale)
    occupancy.select(isFirst: viewModel.initialIsTeam)

    
    table.rx
      .modelSelected(ProfileEditCellModel.self)
      .bind { [unowned self] model in
        self.modelSelected.onNext(model)
      }.disposed(by: disposeBag)
    


    table.rx
      .setDelegate(self)
      .disposed(by: disposeBag)

    avatarView.rx
      .tapGesture()
      .when(.recognized)
      .mapToVoid()
      .bind { [unowned self] _ in
        self.picker = ImagePicker(presentationController: self, delegate: self)
        self.picker!.present(from: self.view)
      }
      .disposed(by: disposeBag)

    viewModel
      .loading
      .asObservable()
      .bind { [unowned self] isLoading in
        self.save.isEnabled = !isLoading
      }
      .disposed(by: disposeBag)

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
    
    
    /*
    viewModel
      .statisticData
      .bind { [unowned self] data in
        self.statisticView.setup(statNum: data.0, rate: data.1)
      }
        .disposed(by: disposeBag) */
  }
}

// MARK: - Constraints
extension ProfileModule.Edit.ViewController {
  func setupConstraints() {
    //selfScoring.isHidden = true

    view.backgroundColor = Colors.screenBg
    self.scrollview = Components.addScrollView(to: view)
    
    
    phoneNumberTextField = FPNTextField(frame: CGRect(x: 0, y: 0, width: view.bounds.width - 16, height: 50))
    
    
    
    phoneNumberTextField.set(phoneNumber: ProfileService.shared.profile!.phone)
    
    
    
    let stack = Components.stack(arrSub: [], axis: .vertical)
    self.scrollview.addSubview(stack)
    stack.makeAnchors { make in
        make.top(equalTo: self.scrollview.top)
        make.bottom(equalTo: self.scrollview.bottom)
        make.leading(equalTo: self.scrollview.leading)
        make.trailing(equalTo: self.scrollview.trailing)
        make.width(equalTo: self.scrollview.width)
    }

    // MARK: - ava
    let avatarContainer = UIView()
    avatarContainer.backgroundColor = .white
    avatarContainer.backgroundColor = .white
    avatarContainer.makeAnchors { make in
      make.height(100)
    }
    stack.addArrangedSubview(avatarContainer)

    let avatarWhiteView = UIView()
    avatarWhiteView.backgroundColor = .white
    view.addSubview(avatarWhiteView)
    avatarWhiteView.makeAnchors { make in
      make.top(lessThan: view.top)
      make.leading(equalTo: view.leading)
      make.trailing(equalTo: view.trailing)
      make.bottom(equalTo: avatarContainer.top)
    }

    avatarContainer.addSubview(avatarView)
    avatarView.makeAnchors { make in
      make.centerX(equalTo: avatarContainer.centerX)
      make.centerY(equalTo: avatarContainer.centerY)
    }
    
    
    
    let avatarChangeView = UIView()
    avatarChangeView.backgroundColor = Colors.gray6
    avatarView.addSubview(avatarChangeView)
    avatarChangeView.makeAnchors { make in
      make.leading(equalTo: avatarView.leading)
      make.trailing(equalTo: avatarView.trailing)
      make.bottom(equalTo: avatarView.bottom)
      make.top(equalTo: avatarView.centerY)
    }

    let avatarChangeLabel = UILabel()
    avatarChangeLabel.text = "Change"//L10n.Common.change
    avatarChangeLabel.textColor = Colors.accentBlue
    avatarChangeLabel.font = .systemFont(ofSize: 13)
    avatarChangeView.addSubview(avatarChangeLabel)
    avatarChangeLabel.makeAnchors { make in
      make.centerX(equalTo: avatarChangeView.centerX)
      make.centerY(equalTo: avatarChangeView.centerY, constant: -6)
    }

    // MARK: info
    self.navigationItem.setTrailing(barButton: save, animated: true)
    self.navigationItem.setLeading(barButton: close, animated: true)

    let containerView = UIView()
    containerView.backgroundColor = Colors.screenBg
    stack.addArrangedSubview(containerView)
    
    let infoStack = Components.stack(arrSub: [], axis: .vertical)
    infoStack.spacing = 16
    infoStack.full(in: containerView, horOffset: 16, verOffset: 16)
    //infoStack.addArrangedSubview(statisticView)
    //infoStack.addArrangedSubview(selfScoring)
    
    let genderLabel = Components.header(text: L10n.Profile.gender)
    //genderLabel.isHidden = true
    //gender.isHidden = true
    infoStack.addArrangedSubview(genderLabel)
    infoStack.addArrangedSubview(gender)
    
    let employmentLabel = Components.header(text: L10n.Profile.employment)
    infoStack.addArrangedSubview(employmentLabel)
    infoStack.addArrangedSubview(occupancy)

    let bioLabel = Components.header(text: L10n.OtherPerson.bio)
    infoStack.addArrangedSubview(bioLabel)
    infoStack.addArrangedSubview(bio_off)

    let userInformation = Components.header(text: "User Information" )//L10n.Profile.userInformation)
    infoStack.addArrangedSubview(userInformation)
    
    infoStack.addArrangedSubview(table)
    table.translatesAutoresizingMaskIntoConstraints = false
    tableConstraint = table.height(1)
    tableConstraint.isActive = true
  }
}

extension ProfileModule.Edit.ViewController: UITableViewDelegate {
}

extension ProfileModule.Edit.ViewController: ImagePickerDelegate {
  func didSelect(image: UIImage?) {
    
    guard let img = image else { return }
    self.cropViewController = CropViewController(image: img)
    self.cropViewController!.delegate = self
    self.cropViewController!.aspectRatioPickerButtonHidden = true

    present(self.cropViewController!, animated: true, completion: nil)

    
  }
}



extension ProfileModule.Edit.ViewController: CropViewControllerDelegate {
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        self.avatarPicker.onNext(image)
        self.cropViewController?.dismiss(animated: true, completion: nil)
        self.avatarView.image = image
        PhotoService.shared.image = image
    }
}

