//
//  Metric.swift
//  CovidApp
//
//  Created by jerome on 26/03/2020.
//  Copyright © 2020 Jerome TONNELIER. All rights reserved.
//

import UIKit

enum RawValueError: Error {
    case unknownTypeForEnum
}

enum Validation {
    case yes
    case no
    case dontKnow
    case notApplicable
    case ratherNotAnswer
    
    var text: String {
        switch self {
        case .yes             : return "yes".local()
        case .no              : return "no".local()
        case .dontKnow        : return "dontKnow".local()
        case .notApplicable   : return "notApplicable".local()
        case .ratherNotAnswer : return "ratherNotAnswer".local()
        }
    }
}

enum GovernmentMetrics: Int, CaseIterable {
    case fever
    case cough
    case taste
    case throatSoreness
    case diarrhea
    case tired
    case eatDrink
    case breathingIssues
    case age
    case height
    case weight
    case heartDisease
    case diabetese
    case cancer
    case breathingIllness
    case kidney
    case liver
    case pregnant
    case immunodefense
    case immunosupressant
    case postalCode
    
    var displayText: String {
        switch self {
        case .fever            : return "initial fever".local()
        case .cough            : return "initial cough".local()
        case .taste            : return "initial taste".local()
        case .throatSoreness   : return "initial throatSoreness".local()
        case .diarrhea         : return "initial diarrhea".local()
        case .tired            : return "initial tired".local()
        case .eatDrink         : return "initial eatDrink".local()
        case .breathingIssues  : return "initial breathingIssues".local()
        case .age              : return "initial age".local()
        case .height           : return "initial height".local()
        case .weight           : return "initial weight".local()
        case .heartDisease     : return "initial heartDisease".local()
        case .diabetese        : return "initial diabetese".local()
        case .cancer           : return "initial cancer".local()
        case .breathingIllness : return "initial breathingIllness".local()
        case .kidney           : return "initial kidney".local()
        case .liver            : return "initial liver".local()
        case .pregnant         : return "initial pregnant".local()
        case .immunodefense    : return "initial immunodefense".local()
        case .immunosupressant : return "initial immunosupressant".local()
        case .postalCode       : return "initial postalCode".local()
        }
    }
    
    var validationButtons: [Validation] {
        var defaultValues: [Validation] = [.yes, .no]
        switch self {
        case .postalCode: defaultValues.append(.ratherNotAnswer)
        case .pregnant: defaultValues.append(.notApplicable)
        case .heartDisease, .immunodefense, .immunosupressant: defaultValues.append(.dontKnow)
        default: ()
        }
        return defaultValues
    }
    
    enum ValueType {
        case age, weight, height
        
        var values: [Int] {
            switch self {
            case .age: return Array(1...110)
            case .weight: return Array(1...150)
            case .height: return Array(1...240)
            }
        }
        
        var displayValues: [String] {
            switch self {
            case .age: return values.compactMap({ "\($0) ans" })
            case .weight: return values.compactMap({ "\($0) kgs" })
            case .height: return values.compactMap({ "\($0) cm" })
            }
        }
        
        var defaultSelectedIndex: Int {
            switch self {
            case .age: return values.firstIndex(of: 30) ?? 0
            case .weight: return values.firstIndex(of: 60) ?? 0
            case .height: return values.firstIndex(of: 150) ?? 0
            }
        }
    }
    
    var inputValue: ValueType? {
        switch self {
        case .age: return .age
        case .height: return .height
        case .weight: return .weight
        default: return nil
        }
    }
}

enum MetricState {
    case fine
    case condition(_: MetricType)
    
    var color: UIColor {
        switch self {
        case .fine: return Palette.basic.confirmation.color
        case .condition: return Palette.basic.alert.color
        }
    }
    
    var metricIcon: UIImage? {
        switch self {
        case .fine: return UIImage(named: "Metrics-Fine")
        case .condition(let metric): return metric.metricIcon
        }
    }
}

struct MetricStates {
    var metrics: [MetricState]
}

enum MetricType: Int, CaseIterable {
    case drippingNose = 0
    case cough
    case fever
    case throatSoreness
    case breathingIssues
    
    var icon: UIImage? {
        switch self {
        case .drippingNose: return UIImage(named: "drippingNose")
        case .cough: return UIImage(named: "cough")
        case .fever: return UIImage(named: "fever")
        case .throatSoreness: return UIImage(named: "throatSoreness")
        case .breathingIssues: return UIImage(named: "breathingIssues")
        }
    }
    
    var metricIcon: UIImage? {
        switch self {
        case .drippingNose: return UIImage(named: "Metrics-DrippingNose")
        case .cough: return UIImage(named: "Metrics-Cough")
        case .fever: return UIImage(named: "Metrics-Fever")
        case .throatSoreness: return UIImage(named: "Metrics-ThroatSoreness")
        case .breathingIssues: return UIImage(named: "Metrics-BreathingIssues")
        }
    }
    
    var text: String {
        switch self {
        case .drippingNose: return "drippingNose description".local()
        case .cough: return "cough description".local()
        case .fever: return "fever description".local()
        case .throatSoreness: return "throatSoreness description".local()
        case .breathingIssues: return "breathingIssues description".local()
        }
    }
    
    static func from(_ stringValue: String) throws -> MetricType {
        switch stringValue {
        case "hasdrippingnose": return .drippingNose
        case "hasthroatsoreness": return .throatSoreness
        case "hascough": return .cough
        case "hasbreatingissues": return .breathingIssues
        case "hasfever": return .fever
        default: throw RawValueError.unknownTypeForEnum
        }
    }
}

struct Metric {
    let metric: MetricType
    let value: Bool
}

struct Metrics {
    let metrics: [Metric]
}
