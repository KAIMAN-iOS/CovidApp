//
//  SessionController.swift
//  CovidApp
//
//  Created by jerome on 28/03/2020.
//  Copyright © 2020 Jerome TONNELIER. All rights reserved.
//

import Foundation
import KeychainAccess

struct SessionController {
    private static let keychain = Keychain.init(accessGroup: "CovidApp")
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
    
    func clear() {
        try? SessionController.keychain.removeAll()
    }
    
    var userLoggedIn: Bool {
        return SessionController().token != nil
    }
}
