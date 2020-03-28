//
//  Onboarding.swift
//  CovidApp
//
//  Created by jerome on 28/03/2020.
//  Copyright © 2020 Jerome TONNELIER. All rights reserved.
//

import UIKit

enum Onboarding {
    case welcome
    case purpose
    case governement
    case betterWhenShare
    case letsGo
    
    var title: String {
        switch self {
        case .welcome: return "Onboarding welcome title".local()
        case .purpose: return "Onboarding purpose title".local()
        case .governement: return "Onboarding governement title".local()
        case .betterWhenShare: return "Onboarding betterWhenShare title".local()
        case .letsGo: return "Onboarding letsGo title".local()
        }
    }
    
    var subtitle: String {
        switch self {
        case .welcome: return "Onboarding welcome subtitle".local()
        case .purpose: return "Onboarding purpose subtitle".local()
        case .governement: return "Onboarding governement subtitle".local()
        case .betterWhenShare: return "Onboarding betterWhenShare subtitle".local()
        case .letsGo: return "Onboarding letsGo subtitle".local()
        }
    }
    
    var image: UIImage? {
        switch self {
        case .welcome: return UIImage(named: "welcome")
        case .purpose: return UIImage(named: "purpose")
        case .governement: return UIImage(named: "governement")
        case .betterWhenShare: return UIImage(named: "betterWhenShare")
        case .letsGo: return UIImage(named: "letsGo")
        }
    }
}
