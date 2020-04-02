//
//  RequestObject.swift
//  GameOffer
//
//  Created by Jean Philippe on 10/09/2019.
//  Copyright © 2019 jps. All rights reserved.
//

import Foundation
import UIKit
import Alamofire




/**
    Objet à fournir à l'objet API, ExpectedObject etant le type de réponse attendu si la requête à réussie.
 */
class RequestObject<ExpectedObject: Decodable> {
    
    
    typealias RequestObjectCompletionHandler = (_ result: Result<ExpectedObject>) -> Void
    
    let uniqueId: String = UUID().uuidString
    
    var parameters: RequestParameters? {
        return nil
    }
    
    var headers: HTTPHeaders? {
        return nil
    }
    
    var method: HTTPMethod {
        return .get
    }
    
    var endpoint: String? {
        return nil
    }
    
    var uploadFiles: Bool {
        return false
    }
    
    var encoding: ParameterEncoding {
        switch method {
            case .get:  return URLEncoding.default
            default:    return URLEncoding.default
        }
    }
    
    func createMultiPartFormData(_ mpfd: MultipartFormData) {}
    
}

class RequestParameters: Encodable {
}



