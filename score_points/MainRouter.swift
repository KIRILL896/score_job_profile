

import Foundation
import RxSwift
import UIKit
import SwiftMessages

class MainRouter {
  
  // MARK: services
  var profileStorage: ProfileService
  var contentSettings: ContentSettings
  
  // MARK: view configs
  let window : UIWindow
  var mainTabbarController : MainTabController?
  let profileTabTag = 222
  var isProfileControllerSet = false
  
  // MARK: rx
  let disposeBag = DisposeBag()
  var profileDisposable: Disposable?
  
  // MARK: instructor
  var launchInstructor : LaunchInstructor
  
  init(
    launchInstructor: LaunchInstructor,
    profileStorage: ProfileService,
    contentSettings: ContentSettings,
    window : UIWindow
  ) {
    self.launchInstructor = launchInstructor
    self.profileStorage = profileStorage
    self.contentSettings = contentSettings
    self.window = window
  }
  
  func start() {
    profileDisposable?.dispose()
    let launchOption = launchInstructor.launchOption
     switch launchOption {
     case .loading:
       showLoadingScreen()
     case .login:
       let _ = showLoginScreen()
     case .main:
       showMainScreen()
     case .onboarding:
       showOnboardingScreen()
     case .welcome:
       showWelcomeScreen()
     }
 }
  
  func showLoadingScreen() {
    let vc = LoadingViewController.instanceFromStoryboard()
    vc.didFinishConfiguration = { [weak self] in
      DispatchQueue.main.async {
        self?.launchInstructor.showedLoadingController = true
        self?.start()
      }
    }
    setRootViewController(vc)
  }
  
  func showOnboardingScreen() {
    let vc = OnboardingVC.instanceFromStoryboard()
    vc
      .didPressContinue
      .subscribe(onNext : { [weak self] in
        self?.contentSettings.wasShowingOnboarding = true
        self?.start()
      })
      .disposed(by: vc.disposeBag)
    setRootViewController(vc, animated: true)
  }
  
  func showWelcomeScreen() {
    let vc = WelcomeScreen()
    let deps = WelcomeViewModelDependencies(
      contentSettings: ContentSettings.shared
    )
    
    let vm = WelcomeViewModel(deps: deps)
    vc.viewModel = vm
    vm
      .welcomed
      .observeOn(MainScheduler.instance)
      .bind { [unowned self] _ in
        self.start()
      }
      .disposed(by: disposeBag)
    
    setRootViewController(vc, animated: true)
  }

  
  func showLoginScreen() -> LoginRouter {
    let vc = SignInVC.instanceFromStoryboard()
    let router = LoginRouter(sourceViewController: vc)
    let deps = SignInViewModelDependencies(
      loginService: LoginService()
    )
    let vm = SignInViewModel(router: router, deps: deps)
    let nvc = UINavigationController(rootViewController: vc)
    
    vm.loggedIn
      .drive(onNext : { [weak self] in
        self?.start()
      })
      .disposed(by: disposeBag)

    vm.didSkipSignIn
      .asObservable()
      .bind { [weak self] _ in
        print("skipped sign in")
        
         self?.contentSettings.wasSkipAuthorization = true
         self?.start()
       }
      .disposed(by: disposeBag)
    vc.viewModel = vm
    setRootViewController(nvc, animated: true)
    
    return router
  }
  
  func showMainScreen() {
    let tabVC = MainTabController()
    var viewControllers = [UIViewController]()
    
    let mainVC = Home.ViewController()
    let mainRouter = Home.Router(sourceViewController: mainVC)
    let mainDeps = Home.ViewModel.Dependencies(
      profileService: ProfileService.shared,
      blockService: BlockingService.shared,
      usersService: UsersService(),
      scoreService: ScoreService(),
      userGroupService: GroupService(),
      requestService: ScoreRequestService(),
      notificationService: NotificationService_(),
    appInfoService: AppInfoService())
    let mainVM = Home.ViewModel(router: mainRouter, deps: mainDeps)
    mainVC.viewModel = mainVM
    let mainTabItem = UITabBarItem(title: L10n.Tabs.home, image: Images.home.image, tag: 0)
    let mainNVC = UINavigationController(rootViewController: mainVC)
    if #available(iOS 11.0, *) {
      mainNVC.navigationBar.prefersLargeTitles = true
    }
    mainVC.tabBarItem = mainTabItem
    viewControllers.append(mainNVC)
    
    
    
    
    let traitsVC = Traits.TraitsListVC.ViewController()
    let traitsRouter = Traits.Router(sourceViewController: traitsVC)
    let traitsDeps = Traits.TraitsListVC.ViewModel.Dependencies(
        userService: ProfileService.shared,
        scoreService: ScoreService(),
        notificationService:NotificationService_(),
        usersService: UsersService()
    )
    let traitsVM = Traits.TraitsListVC.ViewModel(router: traitsRouter, deps: traitsDeps)
    traitsVC.viewModel = traitsVM
    let traitsTabItem = UITabBarItem(title: L10n.Tabs.blog, image: Images.blog.image, tag: 0)
    let traitsNVC = UINavigationController(rootViewController: traitsVC)
    if #available(iOS 11.0, *) {
        traitsNVC.navigationBar.prefersLargeTitles = true
    }
    traitsVC.tabBarItem = traitsTabItem
    viewControllers.append(traitsNVC)
    


    let profileVC = ProfileModule.Detail.ViewController()
    let profileRouter = ProfileModule.Router(sourceViewController: profileVC)
    let profileDeps = ProfileModule.Detail.ViewModel.Dependencies(
      profileService: ProfileService.shared,
      loginService: LoginService(),
      statisticService: StatisticService(),
      scoreService: ScoreService(),notificationService: NotificationService_(),
        usersService: UsersService())
    let profileVM = ProfileModule.Detail.ViewModel(router: profileRouter, deps: profileDeps)
    profileVC.viewModel = profileVM
    let profileTabItem = UITabBarItem(title: L10n.Tabs.profile, image: Images.profile.image, tag: profileTabTag)
    let profileNVC = UINavigationController(rootViewController: profileVC)
    if #available(iOS 11.0, *) {
      profileNVC.navigationBar.prefersLargeTitles = true
    }
    profileVC.tabBarItem = profileTabItem
    viewControllers.append(profileNVC)
    
    let settingsVC = Settings.Menu.ViewController()
    let settingsRouter = Settings.Router(sourceViewController: settingsVC)
    let settingsDeps = Settings.Menu.ViewModel.Dependencies(
        notificationService:NotificationService_(),
        usersService: UsersService(), appInfoService: AppInfoService())
    let settingsVM = Settings.Menu.ViewModel(router: settingsRouter, deps: settingsDeps)
    settingsVC.viewModel = settingsVM
    let settingsTabItem = UITabBarItem(title: L10n.Tabs.settings, image: Images.more.image, tag: 0)
    let settingsNVC = UINavigationController(rootViewController: settingsVC)
    if #available(iOS 11.0, *) {
      settingsNVC.navigationBar.prefersLargeTitles = true
    }
    settingsVC.tabBarItem = settingsTabItem
    viewControllers.append(settingsNVC)
    
    isProfileControllerSet = true
    
    tabVC.viewControllers = viewControllers
    self.mainTabbarController = tabVC
    setRootViewController(tabVC, animated: true)
    startProfileObserving()
  }
  
  var profileController : UIViewController {
    let vc = ProfileModule.Detail.ViewController()
    let deps = ProfileModule.Detail.ViewModel.Dependencies(
      profileService: ProfileService.shared,
      loginService: LoginService(),
      statisticService: StatisticService(),
      scoreService: ScoreService(),
      notificationService: NotificationService_(),
      usersService: UsersService())
    
    let vm = ProfileModule.Detail.ViewModel(router: ProfileModule.Router.init(sourceViewController: vc), deps: deps)
    vc.viewModel = vm
    
    let profileTabItem = UITabBarItem(
      title: L10n.Tabs.profile,
      image: Images.profile.image, tag: 0
    )
    
    let profileNVC = UINavigationController(rootViewController: vc)
    if #available(iOS 11.0, *) {
      profileNVC.navigationBar.prefersLargeTitles = true
    }
    
    profileTabItem.tag = profileTabTag
    profileNVC.tabBarItem = profileTabItem
    return profileNVC
  }
  
  func startProfileObserving() {
    profileDisposable = profileStorage
      .profileObservable
      .bind(onNext: { [weak self] profile in
        let profile = ProfileService.isStrorageSet()

        if profile == false {
          self?.setEmptyProfileTab()
        } else {
          self?.setExistingProfileTab()
        }
      })
  }
  
  func setEmptyProfileTab() {
    guard let mainTabVC = mainTabbarController,
      var currentControllers = mainTabbarController?.viewControllers,
      let profileTabIndex = mainTabbarController?.viewControllers?.enumerated().filter({ $1.tabBarItem.tag == profileTabTag }).first?.offset  else {
        return
    }

    let vc = SignInVC.instanceFromStoryboard()
    let router = LoginRouter(sourceViewController: vc)
    let deps = SignInViewModelDependencies(
      loginService: LoginService()
    )
    let vm = SignInViewModel(router: router, deps: deps)
    vc.viewModel = vm
    let nvc = UINavigationController(rootViewController: vc)
    let profileTabItem = UITabBarItem(title: L10n.Tabs.profile, image: Images.profile.image, tag: 0)
    profileTabItem.tag = profileTabTag
    vc.tabBarItem = profileTabItem
    
    vm.loggedIn
      .asObservable()
      .bind { [weak self] _ in
        self?.start()
      }
      .disposed(by: disposeBag)
    
    currentControllers.remove(at: profileTabIndex)
    currentControllers.insert(nvc, at: profileTabIndex)
    mainTabVC.viewControllers = currentControllers
    isProfileControllerSet = false

  }
  
  func setExistingProfileTab() {
    guard let mainTabVC = mainTabbarController,
      var currentControllers = mainTabbarController?.viewControllers,
      let profileTabIndex = mainTabbarController?.viewControllers?.enumerated().filter({ $1.tabBarItem.tag == profileTabTag }).first?.offset, !isProfileControllerSet else {
        return
    }
    
    let vc = self.profileController
    currentControllers.remove(at: profileTabIndex)
    currentControllers.insert(vc, at: profileTabIndex)
    mainTabVC.viewControllers = currentControllers
    isProfileControllerSet = true
  }
  
  func setRootViewController(_ controller : UIViewController, animated: Bool = false) {
    if animated {
      UIView.transition(with: window,
                        duration: 0.25,
                        options: .transitionCrossDissolve,
                        animations: {
                          UIView.performWithoutAnimation { [weak self] in
                            guard let self = self else { return }
                            self.window.rootViewController = controller
                            self.window.makeKeyAndVisible()
                          }
      })
    } else {
      window.rootViewController = controller
      window.makeKeyAndVisible()
    }
  }
}
