//
//  RegisterRoute.swift
//  CovidApp
//
//  Created by jerome on 31/03/2020.
//  Copyright © 2020 Jerome TONNELIER. All rights reserved.
//

import Foundation
import UIKit
import Alamofire


// MARK: - UpdateUserRoute RequestObject

/**
 Obtenir les arrêts d’une ligne.
 - Returns: les arrêts dans l’ordre pour une ligne et une destination
 */
class UpdateUserRoute: RequestObject<CurrentUser> {
    // MARK: - RequestObject Protocol
    
    override var method: HTTPMethod {
        .post
    }
    
    override var endpoint: String? {
        "user/post"
    }
    
    override var encoding: ParameterEncoding {
        return JSONEncoding.default
    }
    
    override var parameters: RequestParameters? {
        return UpdateUserParameter(name: name, firstname: firstname, dob: dob)
        //        ["username" :  email! as Any]
    }
    // MARK: Initializers
    let name: String
    let firstname: String
    let dob: String
    
    init(name: String, firstname: String, dob: Date) {
        self.name = name
        self.firstname = firstname
        self.dob = DateFormatter.apiDateFormatter.string(from: dob)
    }
}

class UpdateUserParameter: CovidAppApiCommonParameters {
    let name: String
    let firstname: String
    let dob: String
    
    init(name: String, firstname: String, dob: String) {
        self.name = name
        self.firstname = firstname
        self.dob = dob
    }
    
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case firstname = "firstname"
        case dob = "dob"
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(firstname, forKey: .firstname)
        try container.encode(dob, forKey: .dob)
    }
}

// MARK: - UpdateUserRoute RequestObject

/**
 Obtenir les arrêts d’une ligne.
 - Returns: les arrêts dans l’ordre pour une ligne et une destination
 */
class RetrieveUserRoute: RequestObject<CurrentUser> {
    // MARK: - RequestObject Protocol
    
    override var method: HTTPMethod {
        .get
    }
    
    override var endpoint: String? {
        "user/current"
    }
    
    override var encoding: ParameterEncoding {
        return JSONEncoding.default
    }
    
    override var parameters: RequestParameters? {
        return nil
    }
}
