//
//  SessionController.swift
//  CovidApp
//
//  Created by jerome on 28/03/2020.
//  Copyright © 2020 Jerome TONNELIER. All rights reserved.
//

import Foundation
import KeychainAccess
import SwiftDate
import GoogleSignIn
import FacebookLogin
import AuthenticationServices
import SwiftyUserDefaults

extension DefaultsKeys {
    var loginOrigin: DefaultsKey<Int?> { .init("LoginOrigin", defaultValue: nil) }
}

struct SessionController {
    
    enum LoginOrigin: Int, DefaultsSerializable {
        case facebook, google, apple
    }
    private static let keychain = Keychain.init(service: "CovidApp", accessGroup: "group.com.kaiman.apps")
    private static var instance = SessionController()
    
    var name: String?  {
        set {
            guard let value = newValue else { return }
            try? SessionController.keychain.set(value, key: "name")
        }
        
        get {
            return try? SessionController.keychain.get("name")
        }
    }

    var firstname: String?  {
        set {
            guard let value = newValue else { return }
            try? SessionController.keychain.set(value, key: "firstname")
        }
        
        get {
            return try? SessionController.keychain.get("firstname")
        }
    }
    
    var email: String? {
        set {
            guard let value = newValue else { return }
            try? SessionController.keychain.set(value, key: "email")
        }
        
        get {
            return try? SessionController.keychain.get("email")
        }
    }
    
    var birthday: Date?  {
        set {
            guard let value = newValue else { return }
            try? SessionController.keychain.set(value.toISO(), key: "birthday")
        }
        
        get {
            return try? SessionController.keychain.get("birthday")?.toISODate()?.date
        }
    }
    
    var facebookToken: String?  {
        set {
            guard let value = newValue else { return }
            try? SessionController.keychain.set(value, key: "facebookToken")
        }
        
        get {
            return try? SessionController.keychain.get("facebookToken")
        }
    }
    
    var token: String?  {
        set {
            guard let value = newValue else { return }
            try? SessionController.keychain.set(value, key: "token")
        }
        
        get {
            return try? SessionController.keychain.get("token")
        }
    }
    
    var refreshToken: String?  {
        set {
            guard let value = newValue else { return }
            try? SessionController.keychain.set(value, key: "refreshToken")
        }
        
        get {
            return try? SessionController.keychain.get("refreshToken")
        }
    }
    
    @available(iOS 13.0, *)
    var appleUserData: UserData? {
        set {
            guard let value = newValue else { return }
            if let archived = try? NSKeyedArchiver.archivedData(withRootObject: value, requiringSecureCoding: true) {
                try? SessionController.keychain.set(archived, key: "appleIDCredential")
            }
        }
        
        get {
            guard let data = try? SessionController.keychain.getData("appleIDCredential"),
                let userData = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? UserData else {
                    return nil
            }
            return userData
        }
    }
    
    func clear() {
        // keep the AppleUser Data just in case. When re-login, Apple does not provide the userEmail anymore....
        var appleUserData: UserData? = nil
        if #available(iOS 13.0, *) {
            appleUserData = SessionController().appleUserData
        }
        try? SessionController.keychain.removeAll()
        if #available(iOS 13.0, *) {
            SessionController.instance.appleUserData = appleUserData
        }
    }
    
    var userLoggedIn: Bool {
        return SessionController().email != nil
    }
    
    var userProfileCompleted: Bool {
        return SessionController().name != nil && SessionController().firstname != nil && SessionController().birthday != nil
    }
    
    func readFromFacebook(_ data: [String : String]) {
        Defaults[\.loginOrigin] = LoginOrigin.facebook.rawValue
        read(from: data, for: "email", keyPath: \SessionController.email)
        read(from: data, for: "last_name", keyPath: \SessionController.name)
        read(from: data, for: "first_name", keyPath: \SessionController.firstname)
        if let date = data["birthday"] {
            SessionController.instance.birthday = DateFormatter.facebookDateFormatter.date(from: date)
        }
    }
    
    func readFrom(googleUser user: GIDGoogleUser) {
        Defaults[\.loginOrigin] = LoginOrigin.google.rawValue
        SessionController.instance.name = user.profile.familyName
        SessionController.instance.firstname = user.profile.givenName
        SessionController.instance.email = user.profile.email
    }
    
    @available(iOS 13.0, *)
    func readFrom(appleIDCredential: ASAuthorizationAppleIDCredential) {
        Defaults[\.loginOrigin] = LoginOrigin.apple.rawValue
        guard let email = appleIDCredential.email else {
            if let userData = SessionController.instance.appleUserData {
                SessionController.instance.name = userData.name.familyName
                SessionController.instance.firstname = userData.name.givenName
                SessionController.instance.email = userData.email
            }
            return
        }
        SessionController.instance.name = appleIDCredential.fullName?.familyName
        SessionController.instance.firstname = appleIDCredential.fullName?.givenName
        SessionController.instance.email = email
        let userData = UserData(email: email, name: appleIDCredential.fullName!, identifier: appleIDCredential.user)
        SessionController.instance.appleUserData = userData
    }
    
    private func read(from data: [String : String], for key: String, keyPath: WritableKeyPath<SessionController, String?>) {
        if let data = data[key] {
            SessionController.instance[keyPath: keyPath] = data
        }
    }
    
    func logOut() {
        if let rawOrigin = Defaults[\.loginOrigin], let origin = LoginOrigin.init(rawValue: rawOrigin) {
            switch origin {
            case .google: GIDSignIn.sharedInstance().signOut()
            case .facebook: LoginManager().logOut()
            case .apple: () // nothing so far...
            }
        }
        Defaults[\.loginOrigin] = nil
        clear()
    }
}
