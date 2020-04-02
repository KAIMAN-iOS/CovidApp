//
//  DataManager.swift
//  CovidApp
//
//  Created by jerome on 02/04/2020.
//  Copyright © 2020 Jerome TONNELIER. All rights reserved.
//

import Foundation

class DataManager {
    private static let instance: DataManager = DataManager()
    private var storage = DataStorage()
    
    func store(_ metrics: Metrics) {
        do {
            try DataManager.instance.storage.save(metrics)
        } catch {
            
        }
    }
}
