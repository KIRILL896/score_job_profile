
import UIKit
import RxSwift

class EditSwitchCell: UITableViewCell, Reusable {
  let title: UILabel = {
    let view = UILabel()
    view.font = .systemFont(ofSize: 17)
    view.numberOfLines = 0
    view.textColor = Colors.subtitleText
    return view
  }()
  
  let switcher: UISwitch = {
    let view = UISwitch()
    return view
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
  
    contentView.addSubview(title)
    contentView.addSubview(switcher)

    title.makeAnchors { make in
      make.leading(equalTo: contentView.leading, constant: 16)
      make.top(greaterThan: contentView.top, constant: 10)
      make.bottom(greaterThan: contentView.bottom, constant: -10)
      make.centerY(equalTo: contentView.centerY)
    }
    
    switcher.makeAnchors { make in
      make.trailing(equalTo: contentView.trailing, constant: -16)
      make.top(greaterThan: contentView.top, constant: 10)
      make.bottom(greaterThan: contentView.bottom, constant: -10)
      make.leading(equalTo: title.trailing, constant: 16)
      make.centerY(equalTo: contentView.centerY)
    }
    
    self.separatorInset = .zero

  }
}

extension EditSwitchCell {
  func setup(_ model: SwitchEditCellModel) {
    self.title.text = model.header
    self.switcher.setOn(model.initialValue, animated: true)
    

    
    
    if model.isShowing {
      backgroundColor = .white
    } else {
      backgroundColor = Colors.lightestGray
    }
    
    model.output
      .bind(to: switcher.rx.value)
      .disposed(by: disposeBag)

    switcher.rx.value
      .bind(to: model.input)
      .disposed(by: disposeBag)
  }
}
