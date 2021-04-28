//
//  WelcomeVM.swift
//  imscored
//
//  Created by Влада Кузнецова on 20.07.2020.
//  Copyright © 2020 Winfox. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

struct WelcomeViewModelDependencies {
  let contentSettings: ContentSettings
}

struct WelcomeViewModelBindings {
  let didPressContinue : Driver<Void>
}

class WelcomeViewModel: BaseViewModel {
  let deps: WelcomeViewModelDependencies

  let welcomed = PublishSubject<Void>()

  init(deps: WelcomeViewModelDependencies) {
    self.deps = deps
  }

  func configure(with bindings: WelcomeViewModelBindings) {
    deps.contentSettings.wasShowingWelcome = true
    bindings
      .didPressContinue
      .asObservable()
      .bind(to: welcomed)
      .disposed(by: disposeBag)
  }
}
