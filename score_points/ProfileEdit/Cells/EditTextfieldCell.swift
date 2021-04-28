

import UIKit
import RxSwift

class EditTextfieldCell: UITableViewCell, Reusable {
  let title: UILabel = {
    let view = UILabel()
    view.font = .systemFont(ofSize: 17)
    view.numberOfLines = 0
    view.textColor = Colors.subtitleText
    return view
  }()
  
  let tf: UITextField = {
    let view = UITextField()
    //let newPosition = view.endOfDocument
    //view.selectedTextRange = view.textRange(from: newPosition, to: newPosition)
    view.font = .systemFont(ofSize: 17)
    view.textColor = .black
    view.textAlignment = .inverseNatural
    view.selectedTextRange = view.textRange(from: view.beginningOfDocument, to: view.beginningOfDocument)
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

    backgroundColor = .white
    
    contentView.addSubview(title)
    contentView.addSubview(tf)
    title.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    tf.setContentHuggingPriority(.defaultLow, for: .horizontal)
    tf.selectedTextRange = tf.textRange(from: tf.beginningOfDocument, to: tf.beginningOfDocument)
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

extension EditTextfieldCell {
  func setup(_ model: TextfieldEditCellModel) {
    
    if model.isShowing {
      backgroundColor = .white
    } else {
      backgroundColor = Colors.lightestGray
    }

    print("model placeholder \(model.placeholder)")
    
    self.tf.selectedTextRange = self.tf.textRange(from: self.tf.beginningOfDocument, to: self.tf.beginningOfDocument)
    
    if model.placeholder == "Zip–code" {
        self.tf.keyboardType = .numberPad
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
