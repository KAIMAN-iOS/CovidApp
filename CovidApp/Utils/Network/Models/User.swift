//
//  User.swift
//  CovidApp
//
//  Created by jerome on 26/03/2020.
//  Copyright © 2020 Jerome TONNELIER. All rights reserved.
//

import Foundation
import LetterAvatarKit

class EmptyResponseData: Codable {
}

class BasicUser: Codable {
    private (set) var id: Int
    private (set) var name: String
    private (set) var firstname: String
    
    init() {
        id = 0
        name = ""
        firstname = ""
    }
    
    var icon: UIImage? {
        let color = UIColor.random()
        return LetterAvatarMaker().setCircle(true).setUsername(userName).setLettersColor(color.luminanceValue).setBackgroundColors([color]).build()
    }
    
    var userName: String {
        return firstname + " " + name
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "lastname"
        case firstname = "firstname"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        //mandatory
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        firstname = try container.decode(String.self, forKey: .firstname)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(firstname, forKey: .firstname)
    }
}

class User: BasicUser {
    private (set) var birthdate: Date
    private (set) var cp: String?
    private (set) var metrics: [Metrics]
    
    override init() {
        birthdate = Date(timeIntervalSince1970: 0)
        cp = nil
        metrics = []
        super.init()
    }
    
    var hasSubmittedRportForToday: Bool {
        guard let lastDate = metrics.compactMap({ $0.date }).sorted().last else { return false }
        return lastDate.isToday
    }
    
    enum CodingKeys: String, CodingKey {
        case birthdate = "birthdate"
        case cp = "cp"
        case metrics = "datas"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        print("🐞 \(container.allKeys)")
        if let metrics: [MetricsApiWrapper] = try? container.decode([MetricsApiWrapper].self, forKey: .metrics) {
            self.metrics = metrics.compactMap({ $0.asMetrics })
        } else {
            self.metrics = []
        }
        let dateAsString: String = try container.decodeIfPresent(String.self, forKey: .birthdate) ?? ""
        guard let date = DateFormatter.apiDateFormatter.date(from: dateAsString) else {
            throw DecodingError.keyNotFound(CodingKeys.birthdate, DecodingError.Context(codingPath: [CodingKeys.birthdate], debugDescription: ""))
        }
        birthdate = date
        //optional
        cp = try container.decodeIfPresent(String.self, forKey: .cp)
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(DateFormatter.apiDateFormatter.string(from: birthdate), forKey: .birthdate)
        try container.encode(cp, forKey: .cp)
        try container.encode(metrics.compactMap({ MetricsApiWrapper(metrics: $0) }), forKey: .metrics)
        try super.encode(to: encoder)
    }
}

class CurrentUser: Codable {
    private (set) var sharedUsers: [User]
    private (set) var user: User
    
    init() {
        sharedUsers = []
        user = User()
    }
    
    enum CodingKeys: String, CodingKey {
        case sharedUsers = "shared"
        case currentUser = "current"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        //mandatory
        sharedUsers = try container.decodeIfPresent([User].self, forKey: .sharedUsers) ?? []
        user = try container.decode(User.self, forKey: .currentUser)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(sharedUsers, forKey: .sharedUsers)
        try container.encode(user, forKey: .currentUser)
    }
}
