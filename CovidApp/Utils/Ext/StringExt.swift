//
//  StringExt.swift
//  FindABox
//
//  Created by jerome on 15/09/2019.
//  Copyright © 2019 Jerome TONNELIER. All rights reserved.
//

import UIKit
import NSAttributedStringBuilder

extension String {
    func local() -> String {
        return NSLocalizedString(self, comment: "")
    }
    
    func asAttributedString(for style: FontType, fontScale: CGFloat = 1.0, textColor: UIColor = Palette.basic.primaryTexts.color!, backgroundColor: UIColor = .clear, underline: NSUnderlineStyle? = nil) -> NSAttributedString {
        let attr = AText(self)
            .font(style.font.withSize(style.font.pointSize * fontScale))
            .foregroundColor(textColor)
            .backgroundColor(backgroundColor)
            .attributedString
        
        return underline != nil ? AText.init(attr.string, attributes: attr.attributes(at: 0, effectiveRange: nil)).underline(underline!).attributedString : attr
            
        
        
//        if let underlineStyle = underline {
//            return self.font(style.font.withSize(style.font.pointSize * fontScale)).color(textColor).backgroundColor(backgroundColor).underline(style: underlineStyle)
//        }
//        return self.font(style.font.withSize(style.font.pointSize * fontScale)).color(textColor).backgroundColor(backgroundColor)
    }
}
