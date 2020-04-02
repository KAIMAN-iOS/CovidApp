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
    
    func send(dailyMetrics: Metrics) -> Promise<User> {
        return Promise<User>.init(error: ApiError.noEmail)
    }
    
    func updateUser(name: String, firstname: String, dob: Date) -> Promise<CurrentUser> {
        let route = UpdateUserRoute(name: name, firstname: firstname, dob: dob)
        return perform(route: route)
    }
    
    func post(metric: Metrics) -> Promise<CurrentUser> {
        let route = PostMetricRoute(metric: metric)
        return perform(route: route)
    }
    
    func postInitial(answer: Answers) -> Promise<CurrentUser> {
        let route = PostInitialMetricsRoute(answer: answer)
        return perform(route: route)
    }
}

//MARK:- Internal class for API
private class CovidAppApi: API {
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
    
    var decoder: JSONDecoder {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        return jsonDecoder
    }
}

//MARK:- Common parameters Encodable base class
// make all routes pamraetrs inherit from this class to allow common parameters...
class CovidAppApiCommonParameters: RequestParameters {
}


//MARK:- Covid Private extension
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
}
