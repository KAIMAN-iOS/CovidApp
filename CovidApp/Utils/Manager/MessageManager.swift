//
//  MessageManager.swift
//  maas
//
//  Created by jerome on 12/12/2019.
//  Copyright © 2019 CITYWAY. All rights reserved.
//

import UIKit
import NotificationBannerSwift
import SnapKit
import AudioToolbox
import Loaf

public protocol MessageConfigurable {
    var configuration: MessageDisplayConfiguration { get }
}

public protocol MessageDisplayable {
    var title: String { get }
    var body: String? { get }
    var buttonTitle: String? { get }
}

protocol CustomValueKeyable {
    var stringValue: String { get }
}

extension MessageType: Equatable {}

enum MessageType: MessageConfigurable, MessageDisplayable, Hashable {
    //MARK: - Definitions
    case basic(MessageTypeBasic)
    case request(MessageTypeRequest)
    case sso(MessageTypeSSO)
    
    //MARK: - MessageConfigurable
    var configuration: MessageDisplayConfiguration {
        switch self {
        case .basic(let type): return type.configuration
        case .request(let type): return type.configuration
        case .sso(let type): return type.configuration
        }
    }
    
    //MARK: - MessageDisplayable
    var title: String{
        switch self {
        case .basic(let type): return type.title
        case .request(let type): return type.title
        case .sso(let type): return type.title
        }
    }
    
    var body: String?{
        switch self {
        case .basic(let type): return type.body
        case .request(let type): return type.body
        case .sso(let type): return type.body
        }
    }
    
    var buttonTitle: String?{
        switch self {
        case .basic(let type): return type.buttonTitle
        case .request(let type): return type.buttonTitle
        case .sso(let type): return type.buttonTitle
        }
    }
    
    //MARK: - Hashable
    var hashValue: Int {
        var hasher = Hasher()
        self.hash(into: &hasher)
        return hasher.finalize()
    }
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .basic(type: let type): return type.hash(into: &hasher)
        case .request(type: let type): return type.hash(into: &hasher)
        case .sso(type: let type): return type.hash(into: &hasher)
        }
    }
    
    //MARK: - Equatable
    static func == (lhs: MessageType, rhs: MessageType) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    //MARK: - MessageTypeBasic
    enum MessageTypeBasic: MessageConfigurable, MessageDisplayable {
        
        case custom(title: String, message: String?, buttonTitle: String?, configuration: MessageDisplayConfiguration?)
        case loadingPleaseWait
        case pleaseRetry
        
        func hash(into hasher: inout Hasher) {
            switch self {
            case .custom(let title, let message, _, _):
                hasher.combine(title + (message ?? ""))
            case .loadingPleaseWait:
                hasher.combine(1)
            case .pleaseRetry:
                hasher.combine(2)
            }
            hasher.combine("MessageTypeBasic")
        }
        
        var configuration: MessageDisplayConfiguration {
            switch self {
            case .custom(_, _, _, let config):
                return config ?? MessageDisplayConfiguration()
                
            default: return MessageDisplayConfiguration.line
            }
        }
        
        var title: String {
            switch self {
            case .custom(let title, _, _, _): return title
            case .loadingPleaseWait: return "loading, please wait".local()
            default: return ""
            }
        }
        
        var body: String? {
            switch self {
            case .custom(_, let message, _, _):
                return message
            default:
                return nil
            }
        }
        
        var buttonTitle: String? {
            switch self {
            case .custom(_, _, let buttonTitle, _):
                return buttonTitle
            default:
                return nil
            }
        }
    }
    
    //MARK: - MessageTypeRequest
    enum MessageTypeRequest: MessageConfigurable, MessageDisplayable {
        case noNetwork
        case noResult
        case serverError
        case userNotLoggedIn
        case addFriendFailed
        case cantAddSelf

        func hash(into hasher: inout Hasher) {
            switch self {
            case .noNetwork: hasher.combine(0)
            case .noResult: hasher.combine(1)
            case .serverError: hasher.combine(2)
            case .userNotLoggedIn: hasher.combine(3)
            case .addFriendFailed: hasher.combine(4)
            case .cantAddSelf: hasher.combine(5)
            }
            hasher.combine("MessageTypeRequest")
        }
        
        var configuration: MessageDisplayConfiguration {
            switch self {
            default: return MessageDisplayConfiguration.notification
            }
        }

        var title: String {
            switch self {
            default: return "Oups".local()
            }
        }

        var body: String? {
            switch self {
            case .noNetwork: return "no network".local()
            case .noResult: return "search no result small text".local()
            case .serverError: return "Server error".local()
            case .userNotLoggedIn: return "userNotLoggedIn".local()
            case .addFriendFailed: return "addFriendFailed".local()
            case .cantAddSelf: return "cantAddSelf".local()
            }
        }

        var buttonTitle: String? {
            switch self {
            default: return nil
            }
        }
    }

    //MARK: - MessageTypeSSO
    enum MessageTypeSSO: MessageConfigurable, MessageDisplayable {
        
        case userWasLoggedOut
        case emailNotGranted
        case refreshTokenFailed
        case cantLogin(message: String)
        
        func hash(into hasher: inout Hasher) {
            switch self {
            case .userWasLoggedOut: hasher.combine(0)
            case .emailNotGranted: hasher.combine(1)
            case .refreshTokenFailed: hasher.combine(2)
            case .cantLogin(let message): hasher.combine(message)
            }
            hasher.combine("MessageTypeSSO")
        }

        var configuration: MessageDisplayConfiguration {
            switch self {
            case .userWasLoggedOut:
                var conf = MessageDisplayConfiguration.alert
                conf.buttonConfiguration = ButtonConfiguration()
                return conf
            default: return MessageDisplayConfiguration.alert
            }
        }

        var title: String {
            switch self {
            case .userWasLoggedOut: return ""
            case .emailNotGranted: return "Oups".local()
            case .refreshTokenFailed: return "Oups".local()
            case .cantLogin: return "cantLogin".local()
            }
        }

        var body: String? {
            switch self {
            case .userWasLoggedOut: return "Account logged out".local()
            case .emailNotGranted: return "emailNotGranted".local()
            case .refreshTokenFailed: return "refreshTokenFailed".local()
            case .cantLogin(let message): return message
            }
        }

        var buttonTitle: String? {
            switch self {
            case .userWasLoggedOut: return "Sign in".local()
            default: return nil
            }
        }
    }
}

//MARK: - MessageDisplayConfiguration
public struct MessageDisplayConfiguration {
    var displayType: MessageDisplayType = .default
    var containerView: UIView? = nil
    var duration: Double = 5.0
    var interactiveHide: Bool = true
    var bannerStyle: Loaf.State = .success
    var vibrate: Bool = false
    var buttonConfiguration: ButtonConfiguration? = nil
    var delegate: NotificationBannerDelegate?
    var strokeColor: UIColor? = nil
    var icon: UIImage? = UIImage(named: "ic_event_general")
    var closeTapHandler: ((_ button: UIButton) -> Void)? = nil
    static var line = MessageDisplayConfiguration(displayType: .line, bannerStyle: .success)
    static var card = MessageDisplayConfiguration(displayType: .card, bannerStyle: .success)
    static var alert = MessageDisplayConfiguration(bannerStyle: .error)
    static var notification = MessageDisplayConfiguration()
    
    public static func make(customizeBlock: (inout MessageDisplayConfiguration) -> Void) -> MessageDisplayConfiguration {
        var conf = MessageDisplayConfiguration()
        customizeBlock(&conf)
        return conf
    }
}

//MARK: - ButtonConfiguration
public struct ButtonConfiguration {
    var buttonTextColor: UIColor = Palette.basic.mainTexts.color
    var buttonFont: FontType = FontType.button
    var buttonTapHandler: ((_ button: UIButton) -> Void)? = nil
    var buttonTintColor: UIColor = Palette.basic.alert.color
}

//MARK: - MessageDisplayType
public enum MessageDisplayType {
    case `default` // notificaction style like
    case line // just a simple line
    case card // a card like notificaction with a shadow and round borders
    case points
}

extension UIViewController {
    static var windowController: UIViewController {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.connectedScenes.compactMap({ $0.delegate }).compactMap({ $0 as? SceneDelegate }).first!.appCoordinator.router.navigationController
        }
        return (UIApplication.shared.delegate as! AppDelegate).appCoordinator.router.navigationController
    }
}

//MARK: - MessageManager
class MessageManager {
    private static let instance: MessageManager = MessageManager()
    private var queue: [MessageType] = []
    private var currentMessageType: MessageType? = nil
    
    private init() {
    }
    
    public static func show(_ type: MessageType,
                            in viewController: UIViewController? = nil,
                            buttonTapHandler: ((_ button: UIButton) -> Void)? = nil,
                            closeTapHandler: ((_ button: UIButton) -> Void)? = nil) {
        instance.show(type, in: viewController, buttonTapHandler: buttonTapHandler, closeTapHandler: closeTapHandler)
    }
    
    private func show(_ type: MessageType,
                     in viewController: UIViewController? = nil,
                     buttonTapHandler: ((_ button: UIButton) -> Void)? = nil,
                     closeTapHandler: ((_ button: UIButton) -> Void)? = nil) {
        
        guard queue.contains(type) == false else { return }
        var conf = type.configuration
        conf.buttonConfiguration?.buttonTapHandler = buttonTapHandler
        conf.closeTapHandler = closeTapHandler
        queue.append(type)
        
        switch conf.displayType {
        case .line:
            let loaf = Loaf("\(type.title)\(type.body != nil ? "\n\(type.body!)" : "")", state: conf.bannerStyle, location: .top, presentingDirection: .vertical, dismissingDirection: .vertical, sender: UIViewController.windowController)
            loaf.show(Loaf.Duration.average) {  reason in
                self.queue.removeFirst()
            }
            
        case .card:
            let loaf = Loaf("\(type.title)\(type.body != nil ? "\n\(type.body!)" : "")", state: .custom(Loaf.Style(backgroundColor: Palette.basic.primary.color, textColor: .white, icon: conf.icon)), location: .top, presentingDirection: .vertical, dismissingDirection: .vertical, sender: UIViewController.windowController)
            loaf.show(Loaf.Duration.average) { reason in
                self.queue.removeFirst()
            }
            
        default:
            let loaf = Loaf("\(type.title)\(type.body != nil ? "\n\(type.body!)" : "")", state: .custom(Loaf.Style(backgroundColor: Palette.basic.primary.color, textColor: .white, icon: conf.icon)), location: .top, presentingDirection: .vertical, dismissingDirection: .vertical, sender: UIViewController.windowController)
            loaf.show(Loaf.Duration.average) { reason in
                self.queue.removeFirst()
            }
        }
    }
}
