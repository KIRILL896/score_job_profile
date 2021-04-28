
import Foundation

enum LaunchOption {
  case loading
  case login
  case main
  case onboarding
  case welcome
}

class LaunchInstructor {
  var profileStorage : ProfileService
  var contentSettings : ContentSettings
  var showedLoadingController = false
  
  init(profileStorage : ProfileService, contentSettings: ContentSettings) {
    self.profileStorage = profileStorage
    self.contentSettings = contentSettings
  }
  
  var launchOption : LaunchOption {
    if !showedLoadingController {
      return .loading
    }
    
    
    print("isProfileSetted \(profileStorage.profile), \(contentSettings.wasSkipAuthorization), \(profileStorage.observeOldAuth())")
    
    
    let isProfileSetted = profileStorage.profile != nil
      || contentSettings.wasSkipAuthorization
      || profileStorage.observeOldAuth()
    
    if isProfileSetted && contentSettings.wasShowingWelcome {
        print("returnd man")
       return .main
    } else if isProfileSetted && !contentSettings.wasShowingWelcome {
        print("returnd welcome")
        return .welcome
        
    } else if !contentSettings.wasShowingOnboarding {
        print("returnd onboarding")
        return .onboarding
    } else {
        print("returnd login")
      return .login
    }
  }
}
