

import UIKit
import FirebaseCrashlytics

class MainTabController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
              overrideUserInterfaceStyle = .light
        } else {
              // Fallback on earlier versions
        }
    }
}
