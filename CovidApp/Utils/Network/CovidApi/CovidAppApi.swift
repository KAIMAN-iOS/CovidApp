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
        return api.perform(route).get { response in
            var session = SessionController()
            session.token = response.token
            session.refreshToken = response.refreshToken
        }
    }
    
    func retrieveToken()  -> Promise<RegisterResponse> {
        return register().get { response in
            var session = SessionController()
            session.token = response.token
            session.refreshToken = response.refreshToken
        }
    }
    
    func updateUser(name: String, firstname: String, dob: Date) -> Promise<CurrentUser> {
        let route = UpdateUserRoute(name: name, firstname: firstname, dob: dob)
        return perform(route: route).get { user in
            DataManager().store(user)
        }
    }
    
    func post(metric: Metrics, saveOnFail: Bool = true) -> Promise<CurrentUser> {
        let route = PostMetricRoute(metric: metric)
        return perform(route: route).recover { error -> Promise<CurrentUser> in
            if saveOnFail { DataManager().store(metric) }
            return Promise<CurrentUser>.init(error: error)
        }
    }
    
    func postInitial(answer: Answers) -> Promise<CurrentUser> {
        let route = PostInitialMetricsRoute(answer: answer)
        return perform(route: route)
    }
    
    func retrieveUser() -> Promise<CurrentUser> {
        return perform(route: RetrieveUserRoute()).get { user in
            DataManager().store(user)
        }
    }
    
    func retrieveFriends() -> Promise<[Friend]> {
        return perform(route: FriendRoute())
    }
    
    func deleteFriend(with id: Int) -> Promise<EmptyResponseData> {
        return perform(route: DeleteFriendRoute(id: id))
    }
    
    func addFriend(with email: String) -> Promise<EmptyResponseData> {
        return perform(route: AddFriendRoute(email: email))
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
//                    MessageManager.show(.request(.serverError))
                }
                resolver.reject(error)
            }
        }
    }
    
    func performAndRetry<T>(route: RequestObject<T>) -> Promise<T> {
        func refresh() -> Promise<T> {
            register()
                .then { response -> Promise<T> in
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
