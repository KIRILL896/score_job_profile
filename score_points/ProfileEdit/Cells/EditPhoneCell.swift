

import UIKit
import RxSwift
import InputMask
import FlagPhoneNumber


class EditPhoneCell: UITableViewCell, Reusable {
  let title: UILabel = {
    let view = UILabel()
    view.font = .systemFont(ofSize: 17)
    view.numberOfLines = 0
    view.textColor = Colors.subtitleText
    return view
  }()
  
    
    var phoneNumberTextField:FPNTextField!
    
    
    
  let tf: UITextField = {
    let view = UITextField()
    view.font = .systemFont(ofSize: 17)
    view.textColor = .black
    view.textAlignment = .inverseNatural
    return view
  }()
  
  // MARK: - data
  var disposeBag = DisposeBag()
  private var phoneTextListener : MaskedTextFieldDelegate!
  
  // MARK: - init
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setupConstraint()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setupConstraint()
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    self.disposeBag = DisposeBag()
  }
  
  // MARK: - constraints
  func setupConstraint() {
    self.selectionStyle = .none

    backgroundColor = .white
    
    
    self.phoneNumberTextField = FPNTextField(frame: CGRect(x: 0, y: 0, width:300, height: 50))
    
    phoneTextListener = MaskedTextFieldDelegate()
    phoneTextListener.primaryMaskFormat = L10n.Login.mask
    tf.delegate = self.phoneTextListener
    
    contentView.addSubview(title)
    contentView.addSubview(tf)
    title.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    tf.setContentHuggingPriority(.defaultLow, for: .horizontal)

    title.makeAnchors { make in
      make.leading(equalTo: contentView.leading, constant: 16)
      make.top(greaterThan: contentView.top, constant: 10)
      make.bottom(greaterThan: contentView.bottom, constant: -10)
      make.centerY(equalTo: contentView.centerY)
    }
    
    tf.makeAnchors { make in
      make.trailing(equalTo: contentView.trailing, constant: -16)
      make.top(greaterThan: contentView.top, constant: 10)
      make.bottom(greaterThan: contentView.bottom, constant: -10)
      make.leading(equalTo: title.trailing, constant: 16)
      make.centerY(equalTo: contentView.centerY)
    }
    
    self.separatorInset = .zero
  }
}

extension EditPhoneCell {
  func setup(_ model: PhoneEditCellModel) {
    if model.isShowing {
      backgroundColor = .white
    } else {
      backgroundColor = Colors.lightestGray
    }

    self.title.text = model.header
    self.tf.text = model.initialValue
    self.tf.placeholder = model.placeholder

    self.tf.rx
      .text
      .orEmpty
      .bind(to: model.output)
      .disposed(by: disposeBag)
  }
}
