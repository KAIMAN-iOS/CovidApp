//
//  Double+Extensions.swift
//  mtx
//
//  Created by Jean Philippe on 23/11/2017.
//  Copyright © 2017 Cityway. All rights reserved.
//

import Foundation
import CoreLocation

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
    
    // Convert 1000 meters to 1km
    func km(_ decimals: Int = 1) -> Double {
        return (self/1000).rounded(toPlaces: decimals)
    }
    
    // Convert a Double into localized distance String
    func localizedDistance(addSpace: Bool = true, force: Bool = false) -> String? {
        let returnBlock: () -> String? = {
            if self > 999 {
                if addSpace {
                    return "\(self.km()) \("kilometers short".local())"
                } else {
                    return "\(self.km())\("kilometers short".local())"
                }
            } else {
                if addSpace {
                    return "\(Int(self.rounded(toPlaces: 0))) \("meters short".local())"
                } else {
                    return "\(Int(self.rounded(toPlaces: 0)))\("meters short".local())"
                }
            }
        }
        
        guard force == false else {
            return returnBlock()
        }
            
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined, .restricted, .denied:
            return nil
            
        case .authorizedAlways, .authorizedWhenInUse:
            return returnBlock()
            
        @unknown default:
            return nil
        }
    }
    
    func readablePrice(currency: String = "€") -> String {
        let formatter = NumberFormatter()
        formatter.locale = .current
        formatter.numberStyle = .currency
        formatter.currencySymbol = currency
        return formatter.string(from: self as NSNumber) ?? "n/a"
    }
    
}
