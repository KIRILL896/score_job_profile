

import UIKit
import RxSwift

extension ProfileModule.Detail {
  class Statistic: UIView {
    let disposeBag = DisposeBag()

    let header: UILabel = {
      let view = UILabel()
      view.font = .systemFont(ofSize: 22, weight: .bold)
      view.textColor = .black
      view.text = L10n.Profile.statistic
      return view
    }()
    
    let seeAll: UIButton = {
        let view = UIButton()
        view.setTitleColor(Colors.accentBlue, for: .normal)
        view.setTitle(L10n.Common.seeAll, for: .normal)
        return view
    }()

    let points: UILabel = {
      let view = UILabel()
      view.font = .systemFont(ofSize: 13, weight: .semibold)
      view.textColor = .black
      //view.text = L10n.Common.loading
      return view
    }()
    
    let progress: UIProgressView = {
      let view = UIProgressView()
      view.progressTintColor = Colors.accentBlue
      view.backgroundColor = Colors.gray5
      view.height(4).isActive = true
      return view
    }()
    
    let ratePlace: UILabel = {
      let view = UILabel()
      view.font = .systemFont(ofSize: 13)
      view.textColor = Colors.gray1
      view.text = L10n.Common.loading
      return view
    }()

    // MARK: - init
    override init(frame: CGRect) {
      super.init(frame: frame)
      setupConstraint()
    }
    
    required init?(coder: NSCoder) {
      super.init(coder: coder)
      setupConstraint()
    }
    
    // MARK: - constraints
    func setupConstraint() {
      addSubview(header)
      header.makeAnchors { make in
        make.leading(equalTo: leading)
        make.top(equalTo: top)
      }
      
      addSubview(seeAll)
      seeAll.makeAnchors { make in
        make.trailing(equalTo: trailing)
        make.top(equalTo: top)
      }

      let statView = UIView()
      statView.backgroundColor = .white
      statView.round()
      addSubview(statView)
      statView.makeAnchors { make in
        make.top(equalTo: header.bottom, constant: 8)
        make.leading(equalTo: leading)
        make.trailing(equalTo: trailing)
        make.bottom(equalTo: bottom)
      }
      
      let content = UIStackView(arrangedSubviews: [points, progress, ratePlace])
      content.axis = .vertical
      content.alignment = .fill
      content.distribution = .equalSpacing
      content.spacing = 16
      statView.addSubview(content)
      content.makeAnchors { make in
        make.top(equalTo: statView.top, constant: 16)
        make.leading(equalTo: statView.leading, constant: 16)
        make.trailing(equalTo: statView.trailing, constant: -16)
        make.bottom(equalTo: statView.bottom, constant: -16)
      }
    }

    func setup(statNum: Int, rate: String) {
      if statNum <= 0 {
        ratePlace.text = L10n.Profile.rateLooser
      } else {
        progress.progress = Float(statNum) / 100.0
        ratePlace.text = L10n.Profile.rate(statNum)
      }

      //points.text = L10n.OtherPerson.points(rate)
    }
  }
}
