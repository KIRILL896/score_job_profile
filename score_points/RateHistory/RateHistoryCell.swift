

import UIKit

extension ProfileModule.RateHistory.ViewController {
  class Cell: UITableViewCell, Reusable {
    // MARK: - subviews
    
    
    let starImage: UIImageView = {
      let view = UIImageView()
      view.frame = CGRect(x: 0, y: 0, width: 9, height: 8)
      view.image = UIImage(named: "Star")
      return view
    }()
    
      

      
      
     let scoreValue: UILabel = {
        let view = UILabel()
        view.font = UIFont.systemFont(ofSize: 13)
        view.textColor = UIColor.black
        view.numberOfLines = 0
        return view
      }()
    
    lazy var timeFormatter: DateFormatter = {
      let timeFormatter = DateFormatter()
      timeFormatter.dateFormat = "dd.MM.YYYY"
      return timeFormatter
    }()
    
    
    let circleImage: UIImageView = {
        let view = UIImageView()
        view.frame = CGRect(x: 50, y: 15, width: 12, height: 12)
        view.image = UIImage(named: "CircleStatus")
        return view
    }()
    
    
    let avatar: UIImageView = {
      let view = UIImageView()
      view.round(radius: 22)
      view.backgroundColor = Colors.gray6
      view.contentMode = .center
      view.image = Images.camera.image
      return view
    }()
    
    let name: UILabel = {
      let view = UILabel()
      view.font = .systemFont(ofSize: 17, weight: .bold)
      view.textColor = .black
      view.numberOfLines = 0
      return view
    }()
    
    let phone: UILabel = {
      let view = UILabel()
      view.textColor = Colors.subtitleText
      view.font = UIFont.systemFont(ofSize: 13)
      view.numberOfLines = 0
      return view
    }()
    
    let date: UILabel = {
      let view = UILabel()
      view.textColor = Colors.subtitleText
      view.font = UIFont.systemFont(ofSize: 13)
      view.numberOfLines = 0
      return view
    }()
    
    let pro: UIView = {
      let view = UIView()
      view.layer.cornerRadius = 4
      view.round(radius: 4)
      view.backgroundColor = Colors.gray5
      return view
    }()
    
    let proStatus:UIView = {
        let v = UIView(frame: CGRect(x: 0, y: 0, width: 32, height: 17))
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor.init(red: 229/255, green: 229/255, blue: 234/255, alpha: 1.0)
        v.layer.cornerRadius = 4.0
      
        let proLabel = UILabel()
        proLabel.text = "PRO"
        proLabel.font = UIFont.boldSystemFont(ofSize: 11.0)
        proLabel.textColor = Colors.accentBlue
        proLabel.translatesAutoresizingMaskIntoConstraints = false
      
        v.addSubview(proLabel)
        proLabel.centerY.constraint(equalTo: v.centerY).isActive = true
        proLabel.centerX.constraint(equalTo: v.centerX).isActive = true

      
        return v
    }()
    
    
    
    let proLabel: UILabel = {
      let label = UILabel()
      label.textColor = Colors.accentBlue
      label.text = L10n.Common.pro
      label.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
      return label
    }()
    
    let scoringType: UILabel = {
      let label = UILabel()
      //label.layer.cornerRadius = 4.0
      //label.backgroundColor = Colors.gray5
      label.text = L10n.Scoring.social
      label.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
      return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
      super.init(style: style, reuseIdentifier: reuseIdentifier)
      setupConstraint()
    }
    
    required init?(coder: NSCoder) {
      super.init(coder: coder)
      setupConstraint()
    }
    
    // MARK: - constraints
    func setupConstraint() {
      self.backgroundColor = .white
      
      self.addSubview(avatar)
      avatar.makeAnchors { make in
        make.leading(equalTo: self.leading, constant: 16)
        make.top(greaterThan: self.top, constant: 10)
        make.bottom(greaterThan: self.bottom, constant: 10)
        make.centerY(equalTo: self.centerY)
        make.width(44)
        make.height(44)
      }
      
      self.contentView.addSubview(circleImage)

        
      addSubview(date)
      date.makeAnchors { make in
        make.trailing(equalTo: trailing, constant: -15)
        make.bottom(equalTo: bottom, constant: -8)
      }
      
        
      addSubview(scoreValue)
      scoreValue.makeAnchors { make in
          make.trailing(equalTo: trailing, constant: -15)
          make.bottom(equalTo: date.top, constant:-5)
      }
    
      addSubview(starImage)
      starImage.makeAnchors { make in
        make.trailing(equalTo: scoreValue.leading, constant: -5)
        make.bottom(equalTo: date.top, constant:-9)
      }
        
        
      let scroringType_view = UIView()
      scroringType_view.frame = scoringType.frame
      //scroringType_view.layer.cornerRadius = 4.0
      //scroringType_view.layer.backgroundColor = Colors.gray5.cgColor
      scroringType_view.addSubview(scoringType)
 
      
        
        
      
      let proContainer = Components.stack(arrSub: [pro, scroringType_view], axis: .horizontal)
      //proContainer.spacing = 3
      pro.layer.cornerRadius = 3.0
      pro.addSubview(proLabel)
      proLabel.makeAnchors { make in
        make.centerX(equalTo: pro.centerX)
        make.centerY(equalTo: pro.centerY)
        make.leading(equalTo: pro.leading, constant: 6)
        make.top(equalTo: pro.top, constant: 2)
      }
        
      scoringType.makeAnchors { make in
         make.centerX(equalTo: scroringType_view.centerX)
         make.centerY(equalTo: scroringType_view.centerY)
         make.leading(equalTo: scroringType_view.leading, constant: 5)
         make.trailing(equalTo: scroringType_view.trailing, constant: -5)
      }
        
        
      
      let stack = UIStackView(arrangedSubviews: [proContainer, name, phone])
      stack.axis = .vertical
      stack.alignment = .leading
      stack.distribution = .equalSpacing
      stack.spacing = 0.2
      self.addSubview(stack)
      stack.setContentHuggingPriority(.defaultLow, for: .horizontal)
      date.setContentHuggingPriority(.defaultHigh, for: .horizontal)
      
        

      stack.makeAnchors { make in
        make.leading(equalTo: avatar.trailing, constant: 16)
        make.centerY(equalTo: self.centerY)
      }
    
    
        
        
    
    }
  }
}

extension ProfileModule.RateHistory.ViewController.Cell {
  func setup(model: RateHistoryCellModel) {
    
    if model.type == "scoredByMe" {
        starImage.isHidden = true
        scoreValue.isHidden = true
    }
    
    self.avatar.set(url: model.user.selfie)
    self.name.text = model.user.getName()
    self.phone.text = model.user.phone
    let status = model.user.proStatus == nil ? true : !model.user.proStatus!
    self.pro.isHidden = status
    
    
    
    self.scoreValue.text = String(format: "%.1f", model.rate.value)
    self.date.text = self.timeFormatter.string(from: model.rate.created)
    
    let scoringTypeName: String
    switch model.rate.category {
        case 0:
          scoringTypeName = "Social Scoring"//L10n.Scoring.social
        case 1:
          scoringTypeName =  "Social Scoring" //Self-Employed Scoring"//L10n.Scoring.selfEmployed
        case 2:
            if model.rate.scores.count == 11 {
                scoringTypeName =  "Self-Employed Scoring"
            } else {
                scoringTypeName =  "Team Scoring"
            }
        default:
          scoringTypeName = "Team Scoring"//L10n.Scoring.team
        }

    self.scoringType.text = scoringTypeName
    
  }
}
