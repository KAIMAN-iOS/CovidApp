//
//  CLLocation+Extensions.swift
//  mtx
//
//  Created by Julien Goudet on 30/11/2016.
//  Copyright © 2016 Cityway. All rights reserved.
//

import Foundation

import CoreLocation



extension CLLocation {
    
    var asCoordinate2D: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
    
}

extension CLLocationCoordinate2D {

    var asLocation: CLLocation {
        return CLLocation(latitude: latitude, longitude: longitude)
    }

}
