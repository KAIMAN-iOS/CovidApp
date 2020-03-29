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

struct SessionController {
    private static let keychain = Keychain.init(accessGroup: "R8CKJFJ8PKcom.kaiman.apps")
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
    
    func clear() {
        try? SessionController.keychain.removeAll()
    }
    
    var userLoggedIn: Bool {
        return SessionController().token != nil
    }
    
    func readFromFacebook(_ data: [String : String]) {
        read(from: data, for: "email", keyPath: \SessionController.email)
        read(from: data, for: "last_name", keyPath: \SessionController.name)
        read(from: data, for: "first_name", keyPath: \SessionController.firstname)
        if let date = data["birthday"] {
            SessionController.instance.birthday = date.toISODate()?.date
        }
    }
    
    private func read(from data: [String : String], for key: String, keyPath: WritableKeyPath<SessionController, String?>) {
        if let data = data[key] {
            SessionController.instance[keyPath: keyPath] = data
        }
    }
}
