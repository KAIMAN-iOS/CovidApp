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

class DeleteFriendRoute: RequestObject<EmptyResponseData> {
    // MARK: - RequestObject Protocol
    
    override var method: HTTPMethod {
        .post
    }
    
    override var endpoint: String? {
        "friend/delete"
    }
    
    override var encoding: ParameterEncoding {
        return JSONEncoding.default
    }
    
    override var parameters: RequestParameters? {
        return DeleteFriendParameter(id: id)
    }
    
    let id: Int!
    init(id: Int) {
        self.id = id
    }
}

class DeleteFriendParameter: CovidAppApiCommonParameters {
    let id: Int
    
    init(id: Int) {
        self.id = id
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
    }
}


