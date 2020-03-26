//
//  AppCoordinator.swift
//  CovidApp
//
//  Created by jerome on 26/03/2020.
//  Copyright © 2020 Jerome TONNELIER. All rights reserved.
//

import Foundation
import SwiftyUserDefaults

extension DefaultsKeys {
    var username: DefaultsKey<String?> { .init("username") }
    var onboardingWasShown: DefaultsKey<Bool> { .init("onboardingWasShown", defaultValue: false) }
}

fileprivate var onboardingWasShown: Bool {
    return Defaults[\.onboardingWasShown]
}

fileprivate enum LaunchInstructor {
    case main, onboarding
    
    static func configure(
        tutorialWasShown: Bool = onboardingWasShown) -> LaunchInstructor {
        
        switch tutorialWasShown {
        case false: return .onboarding
        case true: return .main
        }
    }
}

class AppCoordinator: Coordinator<DeepLink> {
    
    let mainController = MainViewController.create()
    
    private var instructor: LaunchInstructor {
        return LaunchInstructor.configure()
    }
    
//    private lazy var tabControllers: [Coordinator<DeepLink>] = getCoordinators()
    
    override init(router: RouterType) {
        super.init(router: router)
        router.setRootModule(mainController, hideBar: true)
    }
}
