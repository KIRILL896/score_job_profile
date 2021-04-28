import UIKit
import RxSwift

extension Score.List {
  class Cell: UITableViewCell, Reusable {
    var disposeBag = DisposeBag()
    
    let title: UILabel = {
      let view = UILabel()
      view.font = .systemFont(ofSize: 17)
      view.numberOfLines = 0
      view.textColor = .black
      return view
    }()
    
    let subtitle: UILabel = {
      let view = UILabel()
      view.font = .systemFont(ofSize: 17)
      view.textColor = Colors.accentBlue
      view.textAlignment = .inverseNatural
      view.numberOfLines = 1
      return view
    }()

    let descrContainer = UIView()
    let descr: UILabel = {
      let view = UILabel()
      view.font = .systemFont(ofSize: 17)
      view.textColor = Colors.gray1
      view.textAlignment = .natural
      view.numberOfLines = 0
      return view
    }()
    
    let pickerContainer = UIView()
    let picker: ScorePickerView = {
      let picker = ScorePickerView()
        picker.hero.modifiers = [
          .whenAppearing(.translate(x: 300, y: 0, z: 0)),
          .whenDisappearing(.translate(x: -300, y: 0, z: 0))
        ]
      return picker
    }()
    
    let pickerTopDivider = Components.divider(axis: .horizontal, alpha: 0.5)
    let descrTopDivider = Components.divider(axis: .horizontal, alpha: 0.5)
    
    var isHidenValue:Bool = true
    
    var isHiddenAdditional: Bool {
      return pickerContainer.isHidden
    }

    // MARK: - inits
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
      super.init(style: style, reuseIdentifier: reuseIdentifier)
      setupConstraint()
      setupSlider()
    }
    
    required init?(coder: NSCoder) {
      super.init(coder: coder)
      setupConstraint()
      setupSlider()
    }
    
    override func prepareForReuse() {
      self.disposeBag = DisposeBag()
      picker.disposeBag = DisposeBag()
      picker.selectMiddle()
      hideAdditional()
      setupSlider()
    }
    
    // MARK: - RX
    let value = PublishSubject<Float>()

    func setupSlider() {
      let sliderMoves = picker.selectedValue
        .asObservable()
        .map { value -> Float in
          return Float(value)
        }
    
      sliderMoves
        .bind(to: value)
        .disposed(by: disposeBag)

      value
        .bind { [unowned self] value in
          self.picker.select(value: value)
          self.subtitle.text = Double(value).string(fractionDigits: 1)
        }
        .disposed(by: disposeBag)
    }
    
    // MARK: - constraints
    func setupConstraint() {
      selectionStyle = .none

      backgroundColor = .white
      picker.full(in: pickerContainer, horOffset: 16, verOffset: 8)
      descr.full(in: descrContainer, horOffset: 16, verOffset: 8)

      pickerContainer.addSubview(pickerTopDivider)
      pickerTopDivider.makeAnchors { make in
        make.leading(equalTo: pickerContainer.leading)
        make.trailing(equalTo: pickerContainer.trailing)
        make.top(equalTo: pickerContainer.top)
      }

      descrContainer.addSubview(descrTopDivider)
      descrTopDivider.makeAnchors { make in
        make.leading(equalTo: descrContainer.leading)
        make.trailing(equalTo: descrContainer.trailing)
        make.top(equalTo: descrContainer.top)
      }

      let infoContainerView = UIView()
      infoContainerView.backgroundColor = .white
      let stack = Components.stack(arrSub: [
        infoContainerView,
        descrContainer,
        pickerContainer
      ], axis: .vertical)
      stack.full(in: self, verOffset: 6)
      
      stack.arrangedSubviews.forEach { stack.sendSubviewToBack($0) }
      
      infoContainerView.addSubview(title)
      infoContainerView.addSubview(subtitle)
      
      title.makeAnchors { make in
        make.leading(equalTo: infoContainerView.leading, constant: 16)
        make.top(greaterThan: infoContainerView.top, constant: 8)
        make.bottom(greaterThan: infoContainerView.bottom, constant: -8)
        make.centerY(equalTo: infoContainerView.centerY)
      }
      
      subtitle.makeAnchors { make in
        make.trailing(equalTo: infoContainerView.trailing, constant: -16)
        make.top(greaterThan: infoContainerView.top, constant: 8)
        make.bottom(greaterThan: infoContainerView.bottom, constant: -8)
        make.leading(equalTo: title.trailing, constant: 16)
        make.centerY(equalTo: infoContainerView.centerY)
        make.width(50)
      }
        
        self.descrTopDivider.isHidden = true
        
      [
        descrContainer,
        pickerContainer,
        descr,
        picker,
        descrTopDivider,
        pickerTopDivider
      ].forEach { $0.isHidden = true }
    }
  }
}

extension Score.List.Cell {
  func hideAdditional() {
    UIView.animate(withDuration: 0.3) {
      [
        self.descrContainer,
        self.pickerContainer,
        self.descr,
        self.picker,
      ].forEach { $0.isHidden = true }
        
        self.descrTopDivider.isHidden = true
    }
    
    self.isHidenValue = true

  }
  
  func showAdditional() {
    
    
    UIView.animate(withDuration: 0.3) {
      [
        self.descrContainer,
        self.pickerContainer,
        self.descr,
        self.picker,
      ].forEach { $0.isHidden = false }
      
      self.descrTopDivider.isHidden = true//self.descr.text?.isEmpty ?? true
    }
    
    
    self.isHidenValue = false

  }
}

extension Score.List.Cell {
  func setup(model: Score.ScoreElem) {
    title.text = model.question.name
    descr.text = model.question.description
    descrTopDivider.isHidden = true//model.question.description.isEmpty
    if let evaluate = model.evaluated {
      value.onNext(Float(evaluate))
    } else {
      value.onNext(ScorePickerView.middleVal)
    }
  }
}
