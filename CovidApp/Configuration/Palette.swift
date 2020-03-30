//
//  Palette.swift
//  FindABox
//
//  Created by jerome on 15/09/2019.
//  Copyright © 2019 Jerome TONNELIER. All rights reserved.
//

import UIKit

protocol Colorable {
    var color: UIColor { get }
}

struct Palette {
    enum basic: Colorable {
        case primary
        case secondary
        case background
        case primaryTexts
        case mainTexts
        case secondaryTexts
        case lightGray
        case alert
        case confirmation
        
        var color: UIColor {
            switch self {
            case .primary: return UIColor.init(named: "primary")!
            case .secondary:return UIColor.init(named: "secondary")!
            case .background: return UIColor.init(named: "background")!
            case .primaryTexts:return UIColor.init(named: "primary")!
            case .mainTexts:return UIColor.init(named: "mainTexts")!
            case .secondaryTexts:return UIColor.init(named: "secondaryTexts")!
            case .lightGray:return UIColor.init(named: "lightGray")!
            case .alert:return UIColor.init(named: "alert")!
            case .confirmation:return UIColor.init(named: "confirmation")!
            }
        }
    }
    
    enum bar: Colorable {
        case background
        case title(selected: Bool)
        
        var color: UIColor {
            switch self {
            case .background: return UIColor.init(named: "primaryDark")!
            case .title(let selected): return selected ? UIColor.init(named: "barTitle")! : UIColor.init(named: "barTtitleUnselected")!
            }
        }
    }
}
