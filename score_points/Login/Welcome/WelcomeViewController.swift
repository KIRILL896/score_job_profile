//
//  WelcomeViewController.swift
//  imscored
//
//  Created by Влада Кузнецова on 07.07.2020.
//  Copyright © 2020 Winfox. All rights reserved.
//

import UIKit
import RxSwift

class WelcomeScreen: BaseViewController {
  // MARK: - views
  let textView: UITextView = {
    let view = UITextView()
    view.isScrollEnabled = true
    view.isEditable = false
    view.isSelectable = false
    return view
  }()
    
  let gradientView = UIView()
  
  let acceptButton: UIButton = {
    let view = UIButton()
    view.setTitle(L10n.Common.accept, for: .normal)
    view.setTitleColor(.black, for: .normal)
    view.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
    return view
  }()
  
  // MARK: - rx
  var viewModel: WelcomeViewModel!
    
  override func viewDidLoad() {
    super.viewDidLoad()
    setupViews()
    setupViewModelInput()
    setupViewModelOutput()
    mockData()
    
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    let mask = CAGradientLayer()
    mask.startPoint = CGPoint(x: 0.5, y: 0.0)
    mask.endPoint = CGPoint(x: 0.5, y: 1.0)
    mask.colors = [
      UIColor.white.withAlphaComponent(0.0).cgColor,
      UIColor.white.withAlphaComponent(0.9).cgColor,
      UIColor.white.cgColor
    ]
    
    mask.locations = [
      NSNumber(value: 0.0),
      NSNumber(value: 0.3),
      NSNumber(value: 1.0)
    ]
    mask.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 100)
    
    gradientView.layer.mask = mask
  }
  
  func setupViewModelInput() {
    let bindings = WelcomeViewModelBindings(
      didPressContinue: acceptButton.rx.tap.asDriver()
    )
    
    viewModel.configure(with: bindings)
  }
  
  func setupViewModelOutput() {}
  
  func setupViews() {
    self.view.backgroundColor = .white

    view.addSubview(textView)
    textView.makeAnchors { make in
      make.top(equalTo: view.safeTop)
      make.leading(equalTo: view.leading, constant: 16.0)
      make.trailing(equalTo: view.trailing, constant: -16.0)
      make.bottom(equalTo: view.bottom)
    }
    
    view.addSubview(gradientView)
    gradientView.backgroundColor = .white
    gradientView.makeAnchors { make in
      make.height(100)
      make.leading(equalTo: view.leading)
      make.trailing(equalTo: view.trailing)
      make.bottom(equalTo: view.bottom)
    }
    
    view.addSubview(acceptButton)
    acceptButton.makeAnchors { make in
      make.height(44)
      make.leading(equalTo: view.leading)
      make.trailing(equalTo: view.trailing)
      make.bottom(equalTo: view.safeBottom, constant: 5)
    }
  }
  
  // MARK: - data
  func mockData() {
    
    /*
     <h1>Welcome to IMscored!</h1>
     <p>Please follow these simple rules to be pleased with yourself and get all to the fullest and the best from the IMscored:</p>

     <ul>
         <li>Be who you are - always provide your real personal information</li>
         <li>Be natural - upload your real photo that you like yourself the most. Your contacts will look at that photo when they making your scoring.</li>
         <li>Remember - your contacts cannot see how you scored them, and you cannot see how you had been scored by each of your contacts. Each user of IMscored platform can see only overall personal IMscore</li>
         <li>Be objective, fair and honest - score each person's trait the way you think about them, in real. Do not consider any possible personal conflicts in past. Do not hurry. If in doubt, give a neutral score of 5.0 </li>
         <li>Be magnanimous - do not be offended even if you are not satisfied with your personal IMscore</li>
         <li>Smile!! - your smile prolongs your life, 4sure!!</li>
         <li>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras sit amet est risus. Suspendisse ultricies risus a sem scelerisque accumsan. Ut erat metus, pretium eget erat sed, placerat dapibus purus. Pellentesque tristique aliquam libero, ornare fringilla nisi tempus ut. Vivamus nec lorem a turpis tempus rhoncus id vitae nunc. Nulla tristique, leo ac fringilla commodo, urna sapien eleifend orci, vel condimentum magna purus a tellus. Nullam consectetur lacus eget mi dictum, quis egestas augue pellentesque. Aenean rhoncus nisi id urna cursus scelerisque. Vestibulum feugiat augue in nisi pulvinar, ut viverra sapien porttitor. Pellentesque ultricies, justo et ornare facilisis, mi tellus efficitur libero, eu suscipit est magna eu enim  </li>

     </ul>
     
     */
    
    let text = """
        <style>
        * {
            font-family: '-apple-system';
            margin-bottom: 1em;
        }

        h1 {
            font-size: 20px;
            font-weight: bold;
        }
        div {
            font-size: 17px;
        }

        p {
            text-transform: uppercase;
            font-size: 17px;
        }

        ul {
            list-style-type: '-';
        }

        li {
            font-size: 17px;
            margin: 1em 0;
        }
        </style>
            <h1 style = "text-align:center">Welcome to IMscored!</h1>
            <div>To receive the most optimal IMscored experience, please follow these simple guidelines:</div></br><div>- Scores are personal - you can only interact with users that are found in your contacts</div></br> <div>- Scoring requires consent - you cannot be scored by anyone, as well as you cannot score anyone else without their approval.</div></br> <div>- Scores are anonymous - your contacts cannot see how you scored them, as well as you cannot see how you have been scored by any of your contacts. You can only see your total IMscore and its trait breakdown.</div></br><div>- Be yourself - only provide your actual personal information.</div></br><div>- Be objective, fair, and honest - score each person\'s traits based on the way you really think about them in person. When in doubt, you can give a neutral score of 5.5.</div>
        """
    let inHTML = NSAttributedString(html: text)
    textView.attributedText = inHTML
  }
}
