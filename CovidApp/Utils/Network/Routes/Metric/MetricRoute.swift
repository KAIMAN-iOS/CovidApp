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


// MARK: - PostMetricRoute RequestObject

/**
 Obtenir les arrêts d’une ligne.
 - Returns: les arrêts dans l’ordre pour une ligne et une destination
 */
class PostMetricRoute: RequestObject<CurrentUser> {
    // MARK: - RequestObject Protocol
    
    override var method: HTTPMethod {
        .post
    }
    
    override var endpoint: String? {
        "metric/post"
    }
    
    override var encoding: ParameterEncoding {
        return JSONEncoding.default
    }
    
    override var parameters: RequestParameters? {
        return MetricsApiWrapper(metrics: metric)
        //        ["username" :  email! as Any]
    }
    // MARK: Initializers
    let metric: Metrics
    
    init(metric: Metrics) {
        self.metric = metric
    }
}

// MARK: - PostInitialMetricsRoute RequestObject

/**
 Obtenir les arrêts d’une ligne.
 - Returns: les arrêts dans l’ordre pour une ligne et une destination
 */
class PostInitialMetricsRoute: RequestObject<CurrentUser> {
    // MARK: - RequestObject Protocol
    
    override var method: HTTPMethod {
        .post
    }
    
    override var endpoint: String? {
        "government/post"
    }
    
    override var encoding: ParameterEncoding {
        return JSONEncoding.default
    }
    
    override var parameters: RequestParameters? {
        return answer
        //        ["username" :  email! as Any]
    }
    // MARK: Initializers
    let answer: Answers
    
    init(answer: Answers) {
        self.answer = answer
    }
}
