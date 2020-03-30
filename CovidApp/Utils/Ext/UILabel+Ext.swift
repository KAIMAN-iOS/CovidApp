//
//  UILabel+Ext.swift
//  CovidApp
//
//  Created by jerome on 26/03/2020.
//  Copyright © 2020 Jerome TONNELIER. All rights reserved.
//

import UIKit
import NSAttributedStringBuilder

extension UIColor {
    static var defaultShadowColor: UIColor = UIColor.black.withAlphaComponent(0.3)
}

extension NSShadow {
    static func defaultShadow(with color: UIColor = UIColor.defaultShadowColor) -> NSShadow {
        let shadow = NSShadow()
        shadow.shadowColor = color
        shadow.shadowBlurRadius = 5.0
        shadow.shadowOffset = CGSize(width: 2, height: 2)
        return shadow
    }
}

extension UITextField {
    func set(text: String?, for fontType: FontType, fontScale: CGFloat = 1.0, textColor: UIColor = Palette.basic.primaryTexts.color, backgroundColor: UIColor = .clear, useShadow: Bool = false) {
        guard let attr = text?.asAttributedString(for: fontType, fontScale:fontScale, textColor: textColor, backgroundColor: backgroundColor) else { return }
        if useShadow {
            attributedText = AText.init(attr.string, attributes: attr.attributes(at: 0, effectiveRange: nil)).shadow(color: UIColor.defaultShadowColor, radius: 5.0, x: 2, y: 2).attributedString
        } else {
            attributedText = attr
        }
    }
}

extension UILabel {
    func set(text: String?, for fontType: FontType, fontScale: CGFloat = 1.0, textColor: UIColor = Palette.basic.primaryTexts.color, backgroundColor: UIColor = .clear, useShadow: Bool = false) {
        guard let attr = text?.asAttributedString(for: fontType, fontScale:fontScale, textColor: textColor, backgroundColor: backgroundColor) else { return }
        if useShadow {
            attributedText = AText.init(attr.string, attributes: attr.attributes(at: 0, effectiveRange: nil)).shadow(color: UIColor.defaultShadowColor, radius: 5.0, x: 2, y: 2).attributedString
        } else {
            attributedText = attr
        }
    }
}

