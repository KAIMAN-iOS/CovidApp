//
//  API.swift
//  GameOffer
//
//  Created by Jean Philippe on 10/09/2019.
//  Copyright © 2019 jps. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import PromiseKit


// MARK: Protocol API Implementation
protocol API {
    var baseURL: URL { get }
    var commonHeaders: HTTPHeaders? { get }
    var commonParameters: Parameters? { get }
    var decoder: JSONDecoder { get }
    func send<T>(_ request: RequestObject<T>, completion: @escaping (_ result: Swift.Result<T, AFError>) -> Void) -> Request
}



/**
 Comportement par défaut d'un objet API
 */
extension API {
    
    var decoder: JSONDecoder {
        return JSONDecoder()
    }
    
    var commonParameters: Parameters? {
        return nil
    }
    
    func printRequest<T>(_ request: RequestObject<T>, urlRequest: URLRequest) {
        guard let url = urlRequest.url else { return }
        
        print("\n💬💬💬 Request:")
        print("• URL: \(url)")
        print("• Headers: \(urlRequest.allHTTPHeaderFields ?? [:]))")
        print("• Method: \(request.method)")
        
        if let params = request.parameters {
            print("• Parameters: \(params)")
        }
    }

    /**
     Log dans la console la réponse du serveur, formé de manière à ce que ça soit le plus lisible possible.
     - Parameter dataResponse: Réponse Alamofire
     */
    func printResponse(_ dataResponse: DataResponse<Any, AFError>) {
        print("\n🔵🔵🔵 Response:")
        if let data = dataResponse.data, let code = dataResponse.response?.statusCode, let str = String(data: data, encoding: .utf8), let url = dataResponse.request?.url {
            print("• URL: \(url)")
            print("• Code: \(code)")
            print("• Response: \(str)\n")
        } else if let url = dataResponse.request?.url, let code = dataResponse.response?.statusCode {
            print("• URL: \(url)")
            print("• Code: \(code)")
            print("• Response: <<Empty>>\n")
        } else if let url = dataResponse.request?.url {
            print("• URL: \(url)")
            print("• ERROR")
        }
        if let headers = dataResponse.response?.headers {
            print("• HEADERS")
            print("• \(headers)")
        }
    }
    
    /**
     Envoi d'une requête au serveur.
     - Parameter request: Objet RequestObject, dont le type générique est le type d'objet attendu en retour du webservice (après décodage).
     - Parameter completion: Fonction executée en retour de la requête: Soit success avec l'objet attendu, soit failure avec une erreur.
     - Returns: L'objet Request d'Alamofire, pour avoir la possibilité de cancel() la requête.
     */
    @discardableResult
    func send<T: Decodable>(_ request: RequestObject<T>, completion: @escaping (_ result: Swift.Result<T, AFError>) -> Void) -> Request {
        var urlRequest = try! request.asURLRequest(baseURL: baseURL, commonHeaders: commonHeaders, commonParameters: commonParameters)
        
        printRequest(request, urlRequest: urlRequest)
        
        commonHeaders?.forEach({ urlRequest.setValue($0.value, forHTTPHeaderField: $0.name) })
        
        return AF.request(urlRequest).responseJSON {(dataResponse) in
            self.printResponse(dataResponse)
            completion(self.handleDataResponse(dataResponse))
        }
    }
    
    func request<T: Decodable>(_ request: RequestObject<T>) -> DataRequest {
        var urlRequest = try! request.asURLRequest(baseURL: baseURL, commonHeaders: commonHeaders, commonParameters: commonParameters)
        commonHeaders?.forEach({ urlRequest.setValue($0.value, forHTTPHeaderField: $0.name) })
        printRequest(request, urlRequest: urlRequest)
        return AF.request(urlRequest)
    }
    
    func perform<T: Decodable>(_ request: RequestObject<T>) -> Promise<T> {
        var urlRequest = try! request.asURLRequest(baseURL: baseURL, commonHeaders: commonHeaders, commonParameters: commonParameters)
        commonHeaders?.forEach({ urlRequest.setValue($0.value, forHTTPHeaderField: $0.name) })
        printRequest(request, urlRequest: urlRequest)
        return Promise<T>.init { resolver in
                self.request(request)
                .responseJSON { (dataResponse) in
                    self.printResponse(dataResponse)
                    let result: Swift.Result<T, AFError> = self.handleDataResponse(dataResponse)
                    switch result {
                    case .success(let data): resolver.fulfill(data)
                    case .failure(let error): resolver.reject(error)
                    }
                }
        }
    }
    
    /**
    Traite une réponse Alamofire (DataResponse)
     - Parameter dataResponse: Objet de réponse d'une requête d'alamofire
     */
    private func handleDataResponse<T: Decodable>(_ dataResponse: DataResponse<Any, AFError>) -> Swift.Result<T, AFError> {
        
        let returnError: (_ error: AFError) -> Swift.Result<T, AFError> = { err in
//            let error = NSError(domain: "unknown", code: 0, userInfo: nil)
            print("🆘 Request failed \(err).")
            // Retourner ou faire un print sur err fait crasher l'app ???
            // called; this results in an invalid NSError instance. It will raise an exception in a future release. Please call errorWithDomain:code:userInfo: or initWithDomain:code:userInfo:. This message shown only once.
            return Swift.Result.failure(err)
        }
        
        let returnSuccess: (_ object: T) -> Swift.Result<T, AFError> = { obj in
            print("✅ Request succeeded.")
            return Swift.Result.success(obj)
        }
        
        guard let code = dataResponse.response?.statusCode else {
            return returnError(AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: -1)))
        }

        let handling = handleResponse(data: dataResponse.data, code: code, expectedObject: T.self)
        
        if let error = handling.error {
            return returnError(AFError.responseSerializationFailed(reason: .customSerializationFailed(error: error)))
        } else if let object = handling.object {
            return returnSuccess(object)
        } else {
            return returnError(AFError.responseSerializationFailed(reason: .customSerializationFailed(error: NSError())))
        }
    }
    
    /**
     Traite une réponse du serveur de type Data
     - Parameter data: La data retournée par le serveur
     - Parameter code: Le code HTTP retourné par le serveur
     - Parameter expectedObject: Le type d'objet attendu après décodage du JSON
     
     - Returns: Objet attendu si le décodage de la réponse à réussi (objet), ou erreur s'il a échoué (error)
     */
    private func handleResponse<T: Decodable>(data: Data?, code: Int, expectedObject: T.Type) -> (object: T?, error: Error?) {

        guard let data = data else {
            return (nil, AFError.responseValidationFailed(reason: .dataFileNil))
        }
                
        switch code {
        case 200:
            do {
                let object = try decoder.decode(expectedObject, from: data)
                return (object,nil)
            } catch {
                return (nil, error)
            }
//        case 500: return (nil, AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: 500))))
        default: return (nil, AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: code)))
        }
    }
    
}
