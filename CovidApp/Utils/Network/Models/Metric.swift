//
//  Metric.swift
//  CovidApp
//
//  Created by jerome on 26/03/2020.
//  Copyright © 2020 Jerome TONNELIER. All rights reserved.
//

import UIKit
import SwiftDate
import CoreLocation.CLLocation

enum RawValueError: Error {
    case unknownTypeForEnum
}

protocol Parametarable: Encodable {
    var parameters: [String : Any] { get }
}

//MARK: - Validation
enum Validation {
    case yes
    case `continue`
    case end
    case no
    case dontKnow
    case notApplicable
    case ratherNotAnswer
    case value(_: Int)
    
    var text: String? {
        switch self {
        case .yes             : return "yes".local()
        case .continue        : return "continue".local()
        case .end             : return "terminer".local()
        case .no              : return "no".local()
        case .dontKnow        : return "dontKnow".local()
        case .notApplicable   : return "notApplicable".local()
        case .ratherNotAnswer : return "ratherNotAnswer".local()
        case .value:            return nil
        }
    }
    
    
    var value: String {
        switch self {
        case .yes: return "yes"
        case .continue: return "continue"
        case .end: return "end"
        case .no: return "no"
        case .dontKnow: return "dontKnow"
        case .notApplicable: return "notApplicable"
        case .ratherNotAnswer: return "ratherNotAnswer"
        case .value(let intValue): return "value-\(intValue)"
        }
    }
    
    static func from(value: String) -> Validation? {
        switch value {
        case "yes": return .yes
        case "continue": return .continue
        case "end": return .end
        case "no": return .no
        case "dontKnow": return .dontKnow
        case "notApplicable": return .notApplicable
        case "ratherNotAnswer": return .ratherNotAnswer
        default:
            if let range = value.range(of: "value-") {
                let intValueAsString = value[range.upperBound..<value.endIndex]
                if let intValue = Int(String(intValueAsString)) {
                    return .value(intValue)
                }
            }
            return nil
        }
    }
    
    var actionButtonType: ActionButtonType {
        switch self {
        case .yes             : return .alert
        case .no              : return .primary
        case .continue        : return .primary
        case .end             : return .primary
        case .dontKnow        : return .secondary
        case .notApplicable   : return .secondary
        case .ratherNotAnswer : return .secondary
        case .value:            return .primary
        }
    }
}

extension Validation: Codable {
    
    enum CodingError: Error {
        case unknownValue
    }
    enum Key: CodingKey {
        case rawValue
        case associatedValue
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)
        let rawValue = try container.decode(Int.self, forKey: .rawValue)
        switch rawValue {
        case 0: self = .yes
        case 1: self = .no
        case 2: self = .continue
        case 3: self = .end
        case 4: self = .dontKnow
        case 5: self = .notApplicable
        case 6: self = .ratherNotAnswer
        case 7:
            let intValue = try container.decode(Int.self, forKey: .associatedValue)
            self = .value(intValue)
            
        default: throw CodingError.unknownValue
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Key.self)
        switch self {
            
        case .yes:
            try container.encode(0, forKey: .rawValue)
            
        case .continue:
            try container.encode(1, forKey: .rawValue)
            
        case .end:
            try container.encode(2, forKey: .rawValue)
            
        case .no:
            try container.encode(3, forKey: .rawValue)
            
        case .dontKnow:
            try container.encode(4, forKey: .rawValue)
            
        case .notApplicable:
            try container.encode(5, forKey: .rawValue)
            
        case .ratherNotAnswer:
            try container.encode(6, forKey: .rawValue)
            
        case .value(let intValue):
            try container.encode(7, forKey: .rawValue)
            try container.encode(intValue, forKey: .associatedValue)
        }
    }
}

//MARK: - GovernmentMetrics
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
//    case postalCode
    
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
//        case .postalCode       : return "initial postalCode".local()
        }
    }
    
    var key: String {
        switch self {
        case .fever            : return "fever"
        case .cough            : return "cough"
        case .taste            : return "taste"
        case .throatSoreness   : return "throatSoreness"
        case .diarrhea         : return "diarrhea"
        case .tired            : return "tired"
        case .eatDrink         : return "eatDrink"
        case .breathingIssues  : return "breathingIssues"
        case .age              : return "age"
        case .height           : return "height"
        case .weight           : return "weight"
        case .heartDisease     : return "heartDisease"
        case .diabetese        : return "diabetese"
        case .cancer           : return "cancer"
        case .breathingIllness : return "breathingIllness"
        case .kidney           : return "kidney"
        case .liver            : return "liver"
        case .pregnant         : return "pregnant"
        case .immunodefense    : return "immunodefense"
        case .immunosupressant : return "immunosupressant"
        }
    }
    
    static func from(key: String) -> GovernmentMetrics? {
        switch key {
        case "fever": return .fever
        case "cough": return .cough
        case "taste": return .taste
        case "throatSoreness": return .throatSoreness
        case "diarrhea": return .diarrhea
        case "tired": return .tired
        case "eatDrink": return .eatDrink
        case "breathingIssues": return .breathingIssues
        case "age": return .age
        case "height": return .height
        case "weight": return .weight
        case "heartDisease": return .heartDisease
        case "diabetese": return .diabetese
        case "cancer": return .cancer
        case "breathingIllness": return .breathingIllness
        case "kidney": return .kidney
        case "liver": return .liver
        case "pregnant": return .pregnant
        case "immunodefense": return .immunodefense
        case "immunosupressant": return .immunosupressant
        default: return nil
        }
    }
    
    var validationButtons: [Validation] {
        var defaultValues: [Validation] = [.yes, .no]
        switch self {
        case .age, .height, .weight: return [.continue]
//        case .postalCode: defaultValues.append(.ratherNotAnswer)
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
            case .age:
                guard let birthdate = SessionController().birthday else {
                    return values.firstIndex(of: 30) ?? 0
                }
                let age = birthdate.getInterval(toDate: Date(), component: .year)
                return values.firstIndex(of: Int(age)) ?? 30
                
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
    
    fileprivate var encodedRawValue: Int {
        return GovernmentMetrics.allCases.firstIndex(of: self)!
    }
}

extension GovernmentMetrics: Codable {
    
}

//MARK: - Answers
class Answers: RequestParameters, Decodable {
    internal var data: [GovernmentMetrics : Validation] = [:]
    
    func append(metric: GovernmentMetrics, for validation: Validation) {
        data[metric] = validation
    }
    
    func remove(metric: GovernmentMetrics) {
        data.removeValue(forKey: metric)
    }
    
    override init() { }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        data.forEach { metric, validation in
            let answer: [String:String] = [metric.key : validation.value]
            try? container.encode(answer)
        }
    }
    
    required init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        var wrappedValue: [String:String] = [:]
        while !container.isAtEnd {
            wrappedValue = try container.decode([String:String].self)
            if let key = GovernmentMetrics.from(key: wrappedValue.first?.key ?? ""),
                let value = Validation.from(value: wrappedValue.first?.value ?? "") {
                data[key] = value
            }
        }
    }
}


extension Answers: Parametarable {
    var parameters: [String : Any] {
        var param: [String : Any] = [:]
        data.forEach { (key, value) in
            param[key.key] = value.value
        }
        return param
    }
}

//MARK: - MetricState
//enum MetricState {
//    case fine
//    case condition(_: MetricType)
//    
//    var color: UIColor {
//        switch self {
//        case .fine: return Palette.basic.confirmation.color
//        case .condition: return Palette.basic.alert.color
//        }
//    }
//    
//    var textColor: UIColor {
//        switch self {
//        case .fine: return Palette.basic.mainTexts.color
//        case .condition: return .white
//        }
//    }
//    
//    var displayText: String {
//        switch self {
//        case .fine: return "fine".local()
//        case .condition(let metric): return metric.shortDisplayText
//        }
//    }
//    
//    var metricIcon: UIImage? {
//        switch self {
//        case .fine: return UIImage(named: "Metrics-Fine")
//        case .condition(let metric): return metric.metricIcon
//        }
//    }
//}
//
//struct MetricStates {
//    var metrics: [MetricState]
//}

//MARK: - MetricType
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
    
    var shortDisplayText: String {
        switch self {
        case .drippingNose: return "drippingNose short description".local()
        case .cough: return "cough short description".local()
        case .fever: return "fever short description".local()
        case .throatSoreness: return "throatSoreness short description".local()
        case .breathingIssues: return "breathingIssues short description".local()
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

extension MetricType: Codable {
    
}

//MARK: - Metric
struct Metric {
    let metric: MetricType
    let value: Bool
    
    var color: UIColor {
        return value == true ? Palette.basic.alert.color : Palette.basic.confirmation.color
    }
    
    var textColor: UIColor {
        return .white
    }
    
    var displayText: String {
        return metric.shortDisplayText
    }
}

extension Metric: Comparable {
    static func < (lhs: Self, rhs: Self) -> Bool {
        return lhs.metric.rawValue < rhs.metric.rawValue
    }
}

extension Metric: Codable {
    
}

extension Metric: Parametarable {
    var parameters: [String : Any] {
        return [ "metric" : metric.rawValue, "value" : value ]
    }
}

struct Metrics: Hashable {
    static func == (lhs: Metrics, rhs: Metrics) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    var metrics: [Metric] {
        willSet {
            self.metrics = newValue.sorted()
        }
    }
    let date: Date
    private (set) var coordinates: Coordinate?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(date)
    }
    
    mutating func update(coordinates location: CLLocation) {
        coordinates = Coordinate(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
    }
    
}

struct Coordinate: Codable {
    var latitude: Double
    var longitude: Double
}

extension Metrics: Codable {
    
    enum CodingKeys: CodingKey {
        case metrics
        case date
        case coordinates
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        //mandatory
        metrics = try container.decode([Metric].self, forKey: .metrics)
        date = try container.decode(Date.self, forKey: .date)
        //optional
        coordinates = try container.decodeIfPresent(Coordinate.self, forKey: .coordinates)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(metrics, forKey: .metrics)
        try container.encode(date, forKey: .date)
        try container.encodeIfPresent(coordinates, forKey: .coordinates)
    }
}

extension Metrics: Parametarable {
    var parameters: [String : Any] {
        var param: [String : Any] = [ "metrics" : metrics.compactMap({ $0.parameters }), "date" : date.toISO()]
        if let coordinates = coordinates {
            param["coordinates"] = [ "latitude" : coordinates.latitude, "longitude" : coordinates.longitude ]
        }
        return param
    }
}

// used for mapping the API format
class MetricsApiWrapper: RequestParameters, Decodable {
    var asMetrics: Metrics {
        var coordinate: Coordinate? = nil
        if let lat = latitude, let lon = longitude {
            coordinate = Coordinate(latitude: lat, longitude: lon)
        }
        return Metrics(metrics: [Metric(metric: .fever, value: hasFever), Metric(metric: .drippingNose, value: hasDrippingNose), Metric(metric: .throatSoreness, value: hasThroatSoreness), Metric(metric: .cough, value: hasCough), Metric(metric: .breathingIssues, value: hasBreatingIssues)], date: date ?? Date(), coordinates: coordinate)
    }
    
    let hasFever: Bool
    let hasDrippingNose: Bool
    let hasThroatSoreness: Bool
    let hasCough: Bool
    let hasBreatingIssues: Bool
    let resultDateAsString: String // ISO 8601
    var date: Date? {
        return resultDateAsString.toISODate()?.date
    }
    let latitude: Double?
    let longitude: Double?
    
    enum CodingKeys: String, CodingKey {
        case hasFever = "hasFever"
        case hasDrippingNose = "hasDrippingNose"
        case hasThroatSoreness = "hasThroatSoreness"
        case hasCough = "hasCough"
        case hasBreatingIssues = "hasBreatingIssues"
        case resultDate = "resultDate"
        case latitude = "latitude"
        case longitude = "longitude"
    }
    
    init(metrics: Metrics) {
        hasFever = metrics.metrics.filter({ $0.metric == .fever }).first?.value ?? false
        hasDrippingNose = metrics.metrics.filter({ $0.metric == .drippingNose }).first?.value ?? false
        hasThroatSoreness = metrics.metrics.filter({ $0.metric == .throatSoreness }).first?.value ?? false
        hasCough = metrics.metrics.filter({ $0.metric == .cough }).first?.value ?? false
        hasBreatingIssues = metrics.metrics.filter({ $0.metric == .breathingIssues }).first?.value ?? false
        resultDateAsString = metrics.date.toISO()
        latitude = metrics.coordinates?.latitude
        longitude = metrics.coordinates?.longitude
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        //mandatory
        hasFever = try container.decode(Bool.self, forKey: .hasFever)
        hasDrippingNose = try container.decode(Bool.self, forKey: .hasDrippingNose)
        hasThroatSoreness = try container.decode(Bool.self, forKey: .hasThroatSoreness)
        hasCough = try container.decode(Bool.self, forKey: .hasCough)
        hasBreatingIssues = try container.decode(Bool.self, forKey: .hasBreatingIssues)
        resultDateAsString = try container.decode(String.self, forKey: .resultDate)
        latitude = try? container.decodeIfPresent(Double.self, forKey: .latitude)
        longitude = try? container.decodeIfPresent(Double.self, forKey: .longitude)
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(hasFever, forKey: .hasFever)
        try container.encode(hasDrippingNose, forKey: .hasDrippingNose)
        try container.encode(hasThroatSoreness, forKey: .hasThroatSoreness)
        try container.encode(hasCough, forKey: .hasCough)
        try container.encode(hasBreatingIssues, forKey: .hasBreatingIssues)
        try container.encode(resultDateAsString, forKey: .resultDate)
        try container.encodeIfPresent(latitude, forKey: .latitude)
        try container.encodeIfPresent(longitude, forKey: .longitude)
    }
    
}

