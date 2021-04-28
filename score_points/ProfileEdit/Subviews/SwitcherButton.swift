

import UIKit
import RxSwift

class SwitcherButton: UIView {
  // MARK: - views
  let firstButton: UIButton = {
    let view = UIButton()
    view.setTitleColor(.white, for: .normal)
    view.tintColor = .white
    view.alpha = 1
    return view
  }()
  
  let secondButton: UIButton = {
    let view = UIButton()
    view.setTitleColor(.white, for: .normal)
    view.tintColor = .white
    view.alpha = 0.5
    return view
  }()
  
  // MARK: - rx
  let disposeBag = DisposeBag()
  var isFirstSelected: Bool {
    return firstButton.alpha == 1
  }
  
  private var isFirstSelectedSubj = PublishSubject<Bool>()
  var isFirstSelectedObs: Observable<Bool>
  
  // MARK: - init
  override init(frame: CGRect) {
    self.isFirstSelectedObs = isFirstSelectedSubj.asObservable()
    super.init(frame: frame)
    setupSelecting()
    setupConstraints()
  }

  required init?(coder: NSCoder) {
    self.isFirstSelectedObs = isFirstSelectedSubj.asObservable()
    super.init(coder: coder)
    setupSelecting()
    setupConstraints()
  }
  
  convenience init(firstTitle: String, firstImg: UIImage? = nil, secondTitle: String, secongImg: UIImage? = nil) {
    self.init(frame: .zero)
    translatesAutoresizingMaskIntoConstraints = false
    firstButton.setTitle(firstTitle, for: .normal)
    secondButton.setTitle(secondTitle, for: .normal)
    firstButton.setImage(firstImg, for: .normal)
    secondButton.setImage(secongImg, for: .normal)
  }
  
  func setupSelecting() {
    firstButton.rx
      .tap
      .map { return true }
      .bind(to: isFirstSelectedSubj)
      .disposed(by: disposeBag)
    
    secondButton.rx
      .tap
      .map { return false }
      .bind(to: isFirstSelectedSubj)
      .disposed(by: disposeBag)
    
    isFirstSelectedSubj.bind { [unowned self] isFirst in
        UIView.animate(withDuration: 0.15) { [weak self] in
          self?.firstButton.alpha = isFirst ? 1 : 0.5
          self?.secondButton.alpha = isFirst ? 0.5 : 1
        }
      }
      .disposed(by: disposeBag)
    
  }

  func select(isFirst: Bool) {
    isFirstSelectedSubj.onNext(isFirst)
  }

  // MARK: - constraints
  func setupConstraints() {
    round()
    backgroundColor = Colors.accentBlue
    height(50).isActive = true
    let divider = Components.divider(axis: .vertical)
    divider.backgroundColor = UIColor.black.withAlphaComponent(0.1)
    
    addSubview(divider)
    divider.makeAnchors { make in
      make.centerX(equalTo: centerX)
      make.top(equalTo: top)
      make.bottom(equalTo: bottom)
    }
    
    addSubview(firstButton)
    firstButton.makeAnchors { make in
      make.top(equalTo: top)
      make.bottom(equalTo: bottom)
      make.leading(equalTo: leading)
      make.trailing(equalTo: divider.leading)
    }
    
    addSubview(secondButton)
    secondButton.makeAnchors { make in
      make.top(equalTo: top)
      make.bottom(equalTo: bottom)
      make.trailing(equalTo: trailing)
      make.leading(equalTo: divider.trailing)
    }
  }
}

