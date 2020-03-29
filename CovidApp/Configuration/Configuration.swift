//
//  Configuration.swift
//  CovidApp
//
//  Created by jerome on 26/03/2020.
//  Copyright © 2020 Jerome TONNELIER. All rights reserved.
//

import UIKit
import Foundation

protocol Fontable {
    var font: UIFont { get }
}

enum FontType {
    case bigTitle
    case title
    case button
    case subTitle
    case `default`
    case footnote
}

struct Constants {
    
    enum ComponentShape {
        case capsule
        case rounded(value: CGFloat)
        case square
        
        func applyShape(on view: UIView) {
            switch self {
            case .capsule:
                view.layer.cornerRadius = view.bounds.height / 2
            case .rounded(let value):
                view.layer.cornerRadius = value
            case .square:
                view.layer.cornerRadius = 0
            }
        }
    }
    
    static var defaultComponentShape: Constants.ComponentShape { return .capsule }
}

extension FontType: Fontable {
    var font: UIFont {
        switch self {
        case .bigTitle:
            return Font.style(.title2).bold()
        case .title:
            return Font.style(.headline).bold()
        case .button:
            return Font.style(.subheadline).bold()
        case .subTitle:
            return Font.style(.callout).bold()
        case .default:
            return Font.style(.callout)
        case .footnote:
            return Font.style(.footnote)
        }
    }
}
