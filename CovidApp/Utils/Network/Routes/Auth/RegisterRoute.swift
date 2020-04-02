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


// MARK: - RegisterRoute RequestObject

/**
 Obtenir les arrêts d’une ligne.
 - Parameter routeId
 - Parameter tripHeadSign
 - Returns: les arrêts dans l’ordre pour une ligne et une destination
 */
class RegisterRoute: RequestObject<RegisterResponse> {
    // MARK: - RequestObject Protocol
    
    override var method: HTTPMethod {
        .post
    }
    
    override var endpoint: String? {
        "auth/register"
    }
    
    override var encoding: ParameterEncoding {
        return JSONEncoding.default
    }
    
    override var parameters: RequestParameters? {
        return LoginParameter(username: email!)
//        ["username" :  email! as Any]
    }
        // MARK: - Initializers
    let email: String!
    init?(email: String? = SessionController().email) {
        guard let email = email else { return nil }
        self.email = email
    }
    
}

class LoginParameter: CovidAppApiCommonParameters {
    let username: String
    init(username: String) {
        self.username = username
    }
    
    
    enum CodingKeys: String, CodingKey {
        case username = "username"
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(username, forKey: .username)
    }
}
