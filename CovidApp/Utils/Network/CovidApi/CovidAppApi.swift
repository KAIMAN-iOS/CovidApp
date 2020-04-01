//
//  CovidAppApi.swift
//  CovidApp
//
//  Created by jerome on 31/03/2020.
//  Copyright © 2020 Jerome TONNELIER. All rights reserved.
//
import Foundation
import UIKit
import Alamofire
import PromiseKit


// MARK: - BrestTransportAPI
// -
struct CovidApi {
    private let api = CovidAppApi.shared
    static let shared: CovidApi = CovidApi()
    private init() {}
    
    enum ApiError: Error {
        case noEmail
        case refreshTokenFailed
    }
    
    private func register() -> Promise<RegisterResponse> {
        guard let route = RegisterRoute(email: SessionController().email) else {
            return Promise<RegisterResponse>.init(error: ApiError.noEmail)
        }
        return api.perform(route)
    }
    
    func retrieveToken()  -> Promise<RegisterResponse> {
        return register()
    }
}

private extension CovidApi {
    func perform<T>(route: RequestObject<T>, showMessageOnFail: Bool = true) -> Promise<T> {
        return Promise<T>.init { resolver in
            performAndRetry(route: route)
                .done { object in
                    resolver.fulfill(object)
            }
            .catch { error in
                if showMessageOnFail {
                    MessageManager.show(.request(.serverError))
                }
                resolver.reject(error)
            }
        }
    }
    
    func performAndRetry<T>(route: RequestObject<T>) -> Promise<T> {
        func refresh() -> Promise<T> {
            register()
                .then { _ -> Promise<T> in
                    self.performAndRetry(route: route)
            }
        }
        
        var hasRefreshed: Bool = false
        return
            api
            .perform(route)
            .recover { error -> Promise<T> in
                switch error {
                case AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: 401)) where hasRefreshed == false:
                    // only once
                    hasRefreshed = true
                    print("🐞 refresh token try....")
                    return refresh()
                    
                default: return Promise<T>.init(error: error)
                }
    
        }
    }
    
//    func perform<T>(route: RequestObject<T>, showMessageOnFail: Bool = true) -> Promise<T> {
//        var guarantee = Guarantee()
//        firstly { () -> Guarantee<T> in
//
//        }
//    }
}


private class CovidAppApi: API {
    // MARK: - Properties
    
    // Singleton
    static let shared: CovidAppApi = CovidAppApi()
    
    /// URL de base de l'api Transport de Brest.
    var baseURL: URL {
        URL(string: "http://api.kaiman.fr/public/api")!
    }
    
    /// Headers communs à tous les appels (aucun pour cette api)/
    var commonHeaders: HTTPHeaders? {
        var header = HTTPHeaders.init([HTTPHeader.contentType("application/json")])
        if let token = SessionController().token {
            header.add(HTTPHeader.authorization(bearerToken: token))
        }
        return header
    }
    
    /// Paramètres communs à tous les appels: format = json.
    var commonParameters: Parameters? {
//        ["format": "json"]
        nil
    }
    
    var decoder: JSONDecoder {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        return jsonDecoder
    }
    
}

extension API {
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
}
