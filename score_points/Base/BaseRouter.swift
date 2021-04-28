

import UIKit
import RxSwift

class BaseRouter {
  let disposeBag = DisposeBag()
  weak var sourceViewController: UIViewController?
    
  weak var sub_navigation_controller:UINavigationController?
    
    

  init(sourceViewController: UIViewController?) {
    self.sourceViewController = sourceViewController
  }
  
  func back() {
    sourceViewController?
      .navigationController?
      .popViewController(animated: true)
  }
  
  func toRoot() {
    sourceViewController?
      .navigationController?
      .popToRootViewController(animated: true)
  }
  
  func back(to viewController: UIViewController) {
    sourceViewController?
      .navigationController?
      .popToViewController(viewController, animated: true)
  }
  
    
    
  func closeOnce() {
    sourceViewController?.navigationController?.popViewController(animated: false)

  }
    
  func closeAll() {
    sourceViewController?.dismiss(animated: true, completion: nil)
    sourceViewController?.navigationController?.popViewController(animated: true)
  }
  
  func closeTop() {
    topVC()?.dismiss(animated: true, completion: nil)
  }
  
  func topVC() -> UIViewController? {
    let keyWindow = UIApplication.shared.windows.filter { $0.isKeyWindow }.first

    if var topController = keyWindow?.rootViewController {
        while let presentedViewController = topController.presentedViewController {
            topController = presentedViewController
        }

      return topController
    }
    
    return nil
  }
  
  static func showNotifications(from: UINavigationController) {
    let vc = Settings.NotificationList.ViewController()
    let router = Settings.Router(sourceViewController: vc)
    let deps = Settings.NotificationList.ViewModel.Dependencies(
      notificationService: NotificationService_(),
      userService: UsersService(),
      moduleService: Settings.NotificationService(
        scoreService: ScoreRequestService(),
        profileService: ProfileService.shared,
        userService: UsersService(),
        blockingService: BlockingService.shared,
        router: Home.Router(sourceViewController: nil), scoreService_: ScoreService(), notificationService: NotificationService_()),
      profileService: ProfileService.shared)
    let vm = Settings.NotificationList.ViewModel(router: router, deps: deps)
    vc.viewModel = vm
    from.pushViewController(vc, animated: true)
  }
}
