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
    
    var parameters: Parameters? {
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
    
    func asURLRequest(baseURL: URL, commonHeaders: HTTPHeaders?, commonParameters: Parameters?) throws -> URLRequest {
        let url: URL
        
        if let endpoint = endpoint {
            url = baseURL.appendingPathComponent(endpoint)
        } else {
            url = baseURL
        }
        
        var request = URLRequest(url: url)
        headers?.forEach({ request.setValue($0.value, forHTTPHeaderField: $0.name) })
        request.httpMethod = method.rawValue
        commonHeaders?.forEach({ request.setValue($0.value, forHTTPHeaderField: $0.name) })
        
        let allParameters: Parameters?
        
        switch (commonParameters != nil, parameters != nil) {
        case (true, true):
            allParameters = commonParameters!.merging(parameters!, uniquingKeysWith: { (current, _)  in current })
        case (false, true):
            allParameters = parameters!
        case (true, false):
            allParameters = commonParameters!
        default:
            allParameters = parameters
        }
        
        return try encoding.encode(request, with: allParameters)
    }
    
    func createMultiPartFormData(_ mpfd: MultipartFormData) {}
    
}




