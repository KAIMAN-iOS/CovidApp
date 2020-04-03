//
//  DataManager.swift
//  CovidApp
//
//  Created by jerome on 02/04/2020.
//  Copyright © 2020 Jerome TONNELIER. All rights reserved.
//

import Foundation

typealias StorageKey = String
protocol StorableKey {
    var key: StorageKey { get }
}
enum DataManagerKey: String, StorableKey {
    case currentUser = "CurrentUser"
    case answers = "Answers"
    case storedMetrics = "StoredMetrics"
    
    var key: StorageKey {
        return StorageKey(rawValue)
    }
}

class DataManager {
    private static let instance: DataManager = DataManager()
    private var storage = DataStorage()
    
    func store(_ metrics: Metrics) {
        do {
            try DataManager.instance.storage.save(metrics)
        } catch {
            
        }
    }
    
    func store(_ user: CurrentUser) {
        do {
            try DataManager.instance.storage.save(user)
        } catch {
            
        }
    }
    
    func retrieveUser() throws -> CurrentUser {
        return try retrieve(for: DataManagerKey.currentUser.key)
    }
    
    func retrieve<T: Decodable>(for key: StorageKey) throws -> T {
        do {
            return try DataManager.instance.storage.fetch(for: key)
        }
        catch {
            throw StorageError.notFound
        }
    }
}
