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
    
    override var parameters: Parameters? {
        ["username" :  email! as Any]
    }
        // MARK: - Initializers
    let email: String!
    init?(email: String? = SessionController().email) {
        guard let email = email else { return nil }
        self.email = email
    }
    
}
