

import UIKit
import RxSwift
import RxGesture
import FlagPhoneNumber

class EditSelectCell: UITableViewCell, Reusable {
  let title: UILabel = {
    let view = UILabel()
    view.font = .systemFont(ofSize: 17)
    view.numberOfLines = 0
    view.textColor = Colors.subtitleText
    return view
  }()
    var phoneNumberTextField:FPNTextField!

  
  let subtitle: UILabel = {
    let view = UILabel()
    view.font = .systemFont(ofSize: 17)
    view.textColor = .black
    view.textAlignment = .inverseNatural
    view.numberOfLines = 0
    return view
  }()

    let imageCountru:UIImageView = {
       let v = UIImageView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.widthAnchor.constraint(equalToConstant: 21).isActive = true
        v.heightAnchor.constraint(equalToConstant: 15).isActive = true
        return v
    }()
    
  // MARK: - data
  var disposeBag = DisposeBag()

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

    contentView.addSubview(title)
    contentView.addSubview(subtitle)
    title.setContentHuggingPriority(.defaultLow, for: .horizontal)
    subtitle.setContentHuggingPriority(.defaultHigh, for: .horizontal)

    title.makeAnchors { make in
      make.leading(equalTo: contentView.leading, constant: 16)
      make.top(greaterThan: contentView.top, constant: 10)
      make.bottom(greaterThan: contentView.bottom, constant: -10)
      make.centerY(equalTo: contentView.centerY)
    }
    
    subtitle.makeAnchors { make in
      make.trailing(equalTo: contentView.trailing, constant: -16)
      make.top(greaterThan: contentView.top, constant: 10)
      make.bottom(greaterThan: contentView.bottom, constant: -10)
      make.leading(equalTo: title.trailing, constant: 16)
      make.centerY(equalTo: contentView.centerY)
    }

    contentView.addSubview(imageCountru)
    imageCountru.makeAnchors { make in
      make.trailing(equalTo: subtitle.leading, constant: -5)
      make.centerY(equalTo: contentView.centerY)
    }
  }
}

extension EditSelectCell {
    func setup(_ model: SelectEditCellModel, country:FPNCountry? ) {
    self.title.text = model.header
    self.subtitle.text = model.initialValue
    model.input.bind(to: subtitle.rx.text).disposed(by: disposeBag)
    
    if model.isShowing {
      backgroundColor = .white
    } else {
      backgroundColor = Colors.lightestGray
    }

    
    
    if model.header == "Residence Country" {
        self.separatorInset = UIEdgeInsets(top: 0, left: 10000, bottom: 0, right: 0)
        self.subtitle.text = country?.name
    } else if model.header == "Mobile Number" {
        imageCountru.image = country?.flag
        self.rx
          .tapGesture()
          .when(.recognized)
          .mapToVoid()
          .subscribe(model.output)
          .disposed(by: disposeBag)
    }
    
    

  }
}
