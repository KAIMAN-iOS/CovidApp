//
//  FriendsRoute.swift
//  CovidApp
//
//  Created by jerome on 07/04/2020.
//  Copyright © 2020 Jerome TONNELIER. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
// MARK: - FriendRoute RequestObject

/**
 Obtenir les arrêts d’une ligne.
 - Returns: les arrêts dans l’ordre pour une ligne et une destination
 */
typealias Friend = BasicUser
class FriendRoute: RequestObject<[Friend]> {
    // MARK: - RequestObject Protocol
    
    override var method: HTTPMethod {
        .get
    }
    
    override var endpoint: String? {
        "friend/listing"
    }
    
    override var encoding: ParameterEncoding {
        return JSONEncoding.default
    }
    
    override var parameters: RequestParameters? {
        return nil
    }
}
