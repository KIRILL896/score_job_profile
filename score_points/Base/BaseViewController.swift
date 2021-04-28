

import Foundation
import UIKit
import JGProgressHUD
import SwiftMessages
import RxCocoa
import RxSwift

enum ControllerState {
  case error
  case loading
  case loaded
}

extension Reactive where Base: BaseViewController {
  var controllerState: Binder<ControllerState> {
    return Binder(self.base) { conroller, state in
      conroller.handle(controllerState: state)
    }
  }
  
  var isLoading : Binder<Bool> {
    return Binder(self.base) { controller, bool in
      if bool {
        controller.showActivityHUD()
      } else {
        controller.hideActivityHUD()
      }
    }
  }
}

class BaseViewController: UIViewController {
  
  var isHideNavbar = false
  
  weak var contentToShowView : UIView?
  weak var errorView : UIView?
  weak var loadingView : UIView?
  
  var activityHUD : JGProgressHUD?
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    if #available(iOS 13.0, *) {
          overrideUserInterfaceStyle = .light
      } else {
          // Fallback on earlier versions
      }
    
    if isHideNavbar {
      navigationController?.setNavigationBarHidden(true, animated: false)
    }
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    if isHideNavbar {
      navigationController?.setNavigationBarHidden(false, animated: false)
    }
  }
  
  
  func handle(controllerState : ControllerState) {
    switch controllerState {
    case .error:
      setErrorView(isHidden: false)
      setContentToShow(isHidden: true)
      setLoadingView(isHidden: true)
    case .loaded:
      setErrorView(isHidden: true)
      setContentToShow(isHidden: false)
      setLoadingView(isHidden: true)
    case .loading:
      setErrorView(isHidden: true)
      setContentToShow(isHidden: true)
      setLoadingView(isHidden: false)
    }
  }
  
  func setErrorView(isHidden : Bool) {
    if let errorView = self.errorView {
      errorView.isHidden = isHidden
      if isHidden {
        view.sendSubviewToBack(errorView)
      }
    }
    
  }
  
  func setContentToShow(isHidden : Bool) {
    if let contentToShowView = self.contentToShowView {
      contentToShowView.isHidden = isHidden
      if isHidden {
        view.sendSubviewToBack(contentToShowView)
      }
    }
  }
  func setLoadingView(isHidden : Bool) {
    if let loadingView = self.loadingView {
      loadingView.isHidden = isHidden
      if isHidden {
        view.sendSubviewToBack(loadingView)
      }
    }
  }
  
  
  func showActivityHUD() {
    if let ah = activityHUD, ah.isVisible {
      return
    }
    activityHUD = JGProgressHUD(style: .extraLight)
    activityHUD?.vibrancyEnabled = true
    if let nc = navigationController {
      activityHUD?.show(in: nc.view, animated: true)
    } else {
      activityHUD?.show(in: self.view, animated: true)
    }
    
    activityHUD?.backgroundColor = UIColor.black.withAlphaComponent(0.3)
  }
  
  func hideActivityHUD() {
    activityHUD?.dismiss(animated: true)
  }

  func showErrorToast(with text : String) {
    let message = MessageView.viewFromNib(layout: .cardView)
    message.configureTheme(.error)
    message.button?.isHidden = true
    message.configureContent(title: L10n.Common.error, body: text)
    var config = SwiftMessages.Config()
    config.presentationStyle = .top
    config.presentationContext = .window(windowLevel: .normal)
    config.duration = .seconds(seconds: 3)
    SwiftMessages.hide(animated: false)
    DispatchQueue.main.asyncAfter(wallDeadline: .now() + 0.1) {
      SwiftMessages.show(config: config, view: message)
    }
  }
  
  func showWarningToast(with text : String, title : String? = nil, duration : Double = 3.0) {
    let message = MessageView.viewFromNib(layout: .cardView)
    message.configureTheme(.warning)
    message.button?.isHidden = true
    message.configureContent(title: title ?? L10n.Common.attention, body: text)
    var config = SwiftMessages.Config()
    config.presentationStyle = .top
    config.presentationContext = .window(windowLevel: .normal)
    config.duration = .seconds(seconds: duration)
    SwiftMessages.hide(animated: false)
    DispatchQueue.main.asyncAfter(wallDeadline: .now() + 0.1) {
      SwiftMessages.show(config: config, view: message)
    }
  }
  
  func hideKeyboardWhenTappedAround() {
    let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
    tap.cancelsTouchesInView = true
    view.addGestureRecognizer(tap)
  }
  
  @objc func dismissKeyboard() {
    view.endEditing(true)
  }
  
  // MARK: - notification button
  func addNotificationButton() {
    if let navbar = navigationController?.navigationBar {
      if let _ = NotificationsButton.find(in: navbar) {
        NotificationsButton.replace(in: self)
      } else {
        let favoriteBtn = NotificationsButton.create(in: navbar)
        favoriteBtn.addTarget(self, action: #selector(self.notification(sender:)), for: .touchUpInside)
      }
    }
  }
  
  func hideNotificationButton() {
    guard let navbar = navigationController?.navigationBar,
      let button = NotificationsButton.find(in: navbar)
      else { return }

    UIView.animate(withDuration: 0.25) {
      button.alpha = 0
    }
  }
  
  func showNotificationButton() {
    guard let navbar = navigationController?.navigationBar,
      let button = NotificationsButton.find(in: navbar)
      else { return }

    UIView.animate(withDuration: 0.25) {
      button.alpha = 1
    }
  }

  
  @objc func notification(sender: UIButton!) {
    guard let nav = navigationController else { return }
    BaseRouter.showNotifications(from: nav)
  }
}
