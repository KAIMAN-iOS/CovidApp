//
//  Register.swift
//  CovidApp
//
//  Created by jerome on 01/04/2020.
//  Copyright © 2020 Jerome TONNELIER. All rights reserved.
//

import Foundation

struct RegisterResponse: Decodable {
    let token: String
    let refreshToken: String
    
    
    enum CodingKeys: String, CodingKey {
        case token = "token"
        case refreshToken = "refresh_token"
    }
}
