//
//  AppCoordinator.swift
//  CovidApp
//
//  Created by jerome on 26/03/2020.
//  Copyright © 2020 Jerome TONNELIER. All rights reserved.
//

import UIKit
import SwiftyUserDefaults
import SwiftLocation
import UserNotifications

//MARK: - Protocols
protocol AppCoordinatorDelegate: class {
    func showEmailController()
    func showUserProfileController()
    func showMainController()
    func showInitialMetrics()
    func collectDailyMetrics()
}

protocol ShareDelegate: class {
    func share()
}

//MARK: - Launch
extension DefaultsKeys {
    var username: DefaultsKey<String?> { .init("username") }
    var onboardingWasShown: DefaultsKey<Bool> { .init("onboardingWasShown", defaultValue: false) }
    var initialValuesFilled: DefaultsKey<Bool> { .init("initialValuesFilled", defaultValue: false) }
    var alreadyRequestedNotifications: DefaultsKey<Bool> { .init("alreadyRequestedNotifications", defaultValue: false) }
    var collectedFirstData: DefaultsKey<Bool> { .init("collectedFirstData", defaultValue: false) }
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

//MARK: - AppCoordinator
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
        mainController.shareDelegate = self
        mainController.coordinatorDelegate = self
        customize()
    }
    
    private func customize() {
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().barTintColor = Palette.basic.primary.color
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor : UIColor.white]
    }
    
    override func start() {
        switch instructor {
        case .onboarding: presentOnboardingFlow()
        case .main:
            if SessionController().userLoggedIn == false {
                router.setRootModule(loginController, hideBar: true, animated: false)
            } else {
                showMainController()
            }
        }
    }
    
    func presentOnboardingFlow() {
        SessionController().clear()
        let onboarding = OnboardingViewController.create()
        onboarding.modalPresentationStyle = .overFullScreen
        onboarding.delegate = self
        mainController.present(onboarding, animated: true)
    }
    
    
    lazy var bulletinManager: BLTNItemManager = {
        let manager = BLTNItemManager(rootItem: locationItem)
        if #available(iOS 12.0, *) {
            manager.backgroundViewStyle = .blurredDark
        }
        return manager
    }()
    
    lazy var locationItem: BLTNPageItem = {
        let page = BLTNPageItem(title: "ask location".local())
        page.requiresCloseButton = false
        page.image = UIImage(named: "shareLocation")
        page.descriptionText = "ask for location".local()
        page.actionButtonTitle = "Activate".local()
        page.alternativeButtonTitle = "Not now".local()
        
        page.actionHandler = { item in
            self.bulletinManager.dismissBulletin()
            
            LocationManager.shared.onAuthorizationChange.add { [weak self] state in
                guard state != .undetermined else { return }
                guard let self = self else { return }
            }
            LocationManager.shared.requireUserAuthorization(.whenInUse)
        }
        page.alternativeHandler = { [weak self] item in
            guard let self = self else { return }
            self.bulletinManager.dismissBulletin()
        }
        return page
    } ()
    
    lazy var notificationItem: BLTNPageItem = {
        let page = BLTNPageItem(title: "ask notification".local())
        page.requiresCloseButton = false
        page.image = UIImage(named: "sharePhone")
        page.descriptionText = "ask for notification".local()
        page.actionButtonTitle = "Activate notification".local()
        
        page.actionHandler = { item in
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.alert, .sound]) { granted, error in
                Defaults[\.alreadyRequestedNotifications] = true
                if let error = error {
                    // Handle the error here.
                }
                // Enable or disable features based on the authorization.
            }
        }
        return page
    } ()
    
    func askForLocation() {
        if LocationManager.state == .undetermined {
            bulletinManager.showBulletin(above: mainController)
        }
    }
    
    func askForNotification() {
        if Defaults[\.alreadyRequestedNotifications] == false {
            bulletinManager.push(item: notificationItem)
            bulletinManager.showBulletin(above: mainController)
        }
    }
    
    func send(dailyData: Metrics) {
        CovidApi
            .shared
            .post(metric: dailyData)
            .done { _ in }
    }
    
    func appendLocation(to dailyData: Metrics) {
        guard LocationManager.state == .available || LocationManager.state == .restricted else {
            send(dailyData: dailyData)
            return
        }
        
        LocationManager.shared.locateFromGPS(.significant, accuracy: .house) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure: self.send(dailyData: dailyData)
                
            case .success(let location):
                var updatedData = dailyData
                updatedData.update(coordinates: location)
                self.send(dailyData: updatedData)
            }
        }
    }
}

//MARK: - AppCoordinator extensions
extension AppCoordinator: CloseDelegate {
    func close(_ controller: UIViewController) {
        
        switch controller {
        case is OnboardingViewController:
            Defaults[\.onboardingWasShown] = true
            fallthrough
            
        default:
            mainController.dismiss(animated: true) { }
            start()
        }
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
        if Defaults[\.initialValuesFilled] == false {
            self.showInitialMetrics()
        }
        
        if Defaults[\.alreadyRequestedNotifications] == false {
            Defaults[\.alreadyRequestedNotifications] = true
            askForNotification()
        }
    }
    
    func showInitialMetrics() {
        let coord = CollectDataInitialCoordinator(collectType: .initial)
        coord.closeDelegate = self
        coord.coordinatorDelegate = self
        addChild(coord)
        router.present(coord, animated: true)
        coord.start()
    }
    
    func collectDailyMetrics() {
        let coord = CollectDataInitialCoordinator(collectType: .metrics)
        coord.coordinatorDelegate = self
        coord.collectDelegate = self
        addChild(coord)
        router.present(coord, animated: true)
        coord.start()
    }
}

extension AppCoordinator: ShareDelegate {
    func share() {
        
    }
}

extension AppCoordinator: CollectDataInitialCoordinatorDelegate {
    func didFinishCollect(data: Answers) {
        mainController.dismiss(animated: true, completion: nil)
        CovidApi.shared.postInitial(answer: data).done { _ in
            
        }.catch { error in
            
        }
    }
}

extension AppCoordinator: CollectDailyMetricsDelegate {
    func didCollect(data: Metrics) {
        mainController.dismiss(animated: true, completion: nil)
        
        if LocationManager.state == .undetermined {
            askForLocation()
            LocationManager.shared.onAuthorizationChange.add { [weak self] state in
                guard let self = self else { return }
                self.appendLocation(to: data)
            }
        } else {
            appendLocation(to: data)
        }
        
    }
}

