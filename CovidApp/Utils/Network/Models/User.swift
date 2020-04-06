//
//  User.swift
//  CovidApp
//
//  Created by jerome on 26/03/2020.
//  Copyright © 2020 Jerome TONNELIER. All rights reserved.
//

import Foundation

class User: Codable {
    private (set) var id: Int
    private (set) var name: String
    private (set) var firstname: String
    private (set) var birthdate: Date
    private (set) var cp: String?
    private (set) var metrics: [Metrics]
    
    init() {
        id = 0
        name = ""
        firstname = ""
        birthdate = Date(timeIntervalSince1970: 0)
        cp = nil
        metrics = []
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "lastname"
        case firstname = "firstname"
        case birthdate = "birthdate"
        case cp = "cp"
        case metrics = "datas"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        //mandatory
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        firstname = try container.decode(String.self, forKey: .firstname)
        if let metrics: [MetricsApiWrapper] = try? container.decode([MetricsApiWrapper].self, forKey: .metrics) {
            self.metrics = metrics.compactMap({ $0.asMetrics })
        } else {
            self.metrics = []
        }
        let dateAsString: String = try container.decode(String.self, forKey: .birthdate)
        guard let date = DateFormatter.apiDateFormatter.date(from: dateAsString) else {
            throw DecodingError.keyNotFound(CodingKeys.birthdate, DecodingError.Context(codingPath: [CodingKeys.birthdate], debugDescription: ""))
        }
        birthdate = date
        //optional
        cp = try container.decodeIfPresent(String.self, forKey: .cp)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(firstname, forKey: .firstname)
        try container.encode(DateFormatter.apiDateFormatter.string(from: birthdate), forKey: .birthdate)
        try container.encode(cp, forKey: .cp)
        try container.encode(metrics.compactMap({ MetricsApiWrapper(metrics: $0) }), forKey: .metrics)
    }
}

class CurrentUser: User {
    private (set) var sharedUsers: [User]
    
    override init() {
        sharedUsers = []
        super.init()
    }
    
    enum CodingKeys: String, CodingKey {
        case sharedUsers = "sharedUsers"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        //mandatory
        sharedUsers = try container.decodeIfPresent([User].self, forKey: .sharedUsers) ?? []
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(sharedUsers, forKey: .sharedUsers)
        try super.encode(to: encoder)
    }
}
