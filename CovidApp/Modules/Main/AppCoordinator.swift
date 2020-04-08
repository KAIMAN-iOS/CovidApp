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
    func showSettings()
}

protocol DailyNotificationDelegate: class {
    func updateDailyNotification(for date: Date)
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
    var notificationsEnabled: DefaultsKey<Bool> { .init("notificationsEnabled", defaultValue: false) }
    var collectedFirstData: DefaultsKey<Bool> { .init("collectedFirstData", defaultValue: false) }
    var hourForNotification: DefaultsKey<Date?> { .init("hourForNotification", defaultValue: nil) }
    var dailyNotificationId: DefaultsKey<String> { .init("dailyNotificationId", defaultValue: UUID().uuidString) }
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
    
    func open(from link: DeepLink) {
        switch link {
        case .share(let userId):
            guard SessionController().userLoggedIn == true else {
                MessageManager.show(.request(.userNotLoggedIn), in: mainController)
                return
            }
            CovidApi.shared.addFriend(with: userId).done { [weak self] _ in
                self?.mainController.loadUser()
            }.catch { [weak self] error in
                guard let self = self else { return }
                MessageManager.show(.request(.addFriendFailed), in: self.mainController)
            }
            
        default: ()
        }
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
    
    
    var bulletinManager: BLTNItemManager?
    
    func showBulletin(for item: BLTNItem) {
        bulletinManager = BLTNItemManager(rootItem: item)
        if #available(iOS 12.0, *) {
            bulletinManager?.backgroundViewStyle = .blurredDark
        }
        bulletinManager?.showBulletin(above: mainController)
    }
    
    lazy var locationItem: BLTNPageItem = {
        let page = BLTNPageItem(title: "ask location".local())
        page.requiresCloseButton = false
        page.image = UIImage(named: "shareLocation")
        page.descriptionText = "ask for location".local()
        page.actionButtonTitle = "Activate".local()
        page.alternativeButtonTitle = "Not now".local()
        
        page.actionHandler = { item in
            self.bulletinManager?.dismissBulletin()
            
            LocationManager.shared.onAuthorizationChange.add { [weak self] state in
                guard state != .undetermined else { return }
                guard let self = self else { return }
            }
            LocationManager.shared.requireUserAuthorization(.whenInUse)
        }
        page.alternativeHandler = { [weak self] item in
            guard let self = self else { return }
            self.bulletinManager?.dismissBulletin()
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
            self.bulletinManager?.dismissBulletin()
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.alert, .sound]) { [weak self] granted, error in
                guard let self = self else { return }
                Defaults[\.alreadyRequestedNotifications] = true
                Defaults[\.notificationsEnabled] = granted
                if granted {
                    self.updateNotificationsForDefaultAlarm()
                }
            }
        }
        return page
    } ()
    
    func updateNotificationsForDefaultAlarm() {
        var compo = DateComponents()
        compo.hour = 10
        if let date = Calendar.current.date(from: compo) {
            updateDailyNotification(for: date)
        }
    }
    
    func askForLocation() {
        if LocationManager.state == .undetermined {
            showBulletin(for: locationItem)
        }
    }
    
    func askForNotification() {
        if Defaults[\.alreadyRequestedNotifications] == false {
            showBulletin(for: notificationItem)
        }
    }
    
    func send(dailyData: Metrics) {
        CovidApi
            .shared
            .post(metric: dailyData)
//            .done { _ in }
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
        
        defer {
            // recheck for controller to ask for notification once controller has been dismiss
            mainController.dismiss(animated: true) { [weak self] in
                switch controller {
                case is CollectInitialDataViewController:
                    self?.askForNotification()
                    
                default: ()
                }
            }
            start()
        }
        
        switch controller {
        case is OnboardingViewController:
            Defaults[\.onboardingWasShown] = true
            
        default: ()
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
        // add a callback to check if the user denied notifications then enables them....
         if Defaults[\.alreadyRequestedNotifications] == true, Defaults[\.hourForNotification] == nil {
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.alert, .sound]) { [weak self] granted, error in
                guard let self = self else { return }
                if granted {
                    self.updateNotificationsForDefaultAlarm()
                }
            }
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
    
    func showSettings() {
        let nav = SettingsViewController.createNavigationStack()
        (nav.viewControllers.first as? SettingsViewController)?.closeDelegate = self
        (nav.viewControllers.first as? SettingsViewController)?.notificationDelegate = self
        (nav.viewControllers.first as? SettingsViewController)?.shareDelegate = self
        router.present(nav, animated: true)
    }
}

extension AppCoordinator: ShareDelegate {
    func share() {
        let sharedString = String(format: "share format".local(), SessionController().email ?? "")
        let image = UIImage(named:"AppIcon60x60")!
        mainController.showShareViewController(with:[sharedString, image])
    }
}

extension AppCoordinator: CollectDataInitialCoordinatorDelegate {
    func didFinishCollect(data: Answers) {
        mainController.dismiss(animated: true, completion: nil)
        askForNotification()
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

extension AppCoordinator: DailyNotificationDelegate {
        
    func updateDailyNotification(for date: Date) {
        Defaults[\.hourForNotification] = date
        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = "It's time".local()
        content.body = "Answer your 5 questions".local()
        content.categoryIdentifier = "alarm"
        content.sound = UNNotificationSound.default
        let dateComponents = Calendar.current.dateComponents([.hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        // removes previous notifications just in case...
        center.removeAllPendingNotificationRequests()
        let request = UNNotificationRequest(identifier: Defaults[\.dailyNotificationId], content: content, trigger: trigger)
        center.add(request)
    }
}

extension AppCoordinator: UNUserNotificationCenterDelegate {
    func handleTapOn(_ request: UNNotificationRequest) {
        // if it was a local notification, we have it in our container notificationDatas
        if request.identifier == Defaults[\.dailyNotificationId] {
            collectDailyMetrics()
        } else { // otherwise it is a remote notification
            //TODO:
//            handleRemoteNotificationData(request.content.userInfo, title: request.content.title, body: request.content.body)
        }
    }
    
    /// called when the user clicks on a specific action
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        defer {
            completionHandler()
        }
        // open a notification from outside the app
        handleTapOn(response.notification.request)
    }
    
    /// called when a notification is delivered to the foreground app
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
}
