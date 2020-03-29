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

protocol AppCoordinatorDelegate: class {
    func showEmailController()
    func showUserProfileController()
    func showMainController()
}

class AppCoordinator: Coordinator<DeepLink> {
    
    let mainController = MainViewController.create()
    let loginController = LoginViewController.create()
    
    private var instructor: LaunchInstructor {
        return LaunchInstructor.configure()
    }
    
    override init(router: RouterType) {
        super.init(router: router)
        router.setRootModule(mainController, hideBar: true, animated: false)
        loginController.coordinatorDelegate = self
    }
    
    override func start() {
        switch instructor {
        case .onboarding: presentOnboardingFlow()
        case .main:
            if SessionController().userLoggedIn == false {
                router.setRootModule(loginController, hideBar: true, animated: true)
            } else {
                router.setRootModule(mainController, hideBar: true, animated: true)
            }
        }
    }
    
    func presentOnboardingFlow() {
        let onboarding = OnboardingViewController.create()
        onboarding.modalPresentationStyle = .overFullScreen
        onboarding.delegate = self
        mainController.present(onboarding, animated: true)
    }
}

extension AppCoordinator: CloseDelegate {
    func close() {
        Defaults[\.onboardingWasShown] = true
        mainController.dismiss(animated: true) { }
        start()
    }
}

extension AppCoordinator: AppCoordinatorDelegate {
    func showEmailController() {
        let email = AskEmailViewController.create()
        email.coordinatorDelegate = self
        router.setRootModule(email, hideBar: true, animated: true)
    }
    
    func showUserProfileController() {
        let profile = AskProfileViewController.create()
        profile.coordinatorDelegate = self
        router.setRootModule(profile, hideBar: true, animated: true)
    }
    
    func showMainController() {
        router.setRootModule(mainController, hideBar: true, animated: true)
    }
}
