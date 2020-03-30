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
    
    func asAttributedString(for style: FontType, fontScale: CGFloat = 1.0, textColor: UIColor = Palette.basic.primaryTexts.color, backgroundColor: UIColor = .clear, underline: NSUnderlineStyle? = nil) -> NSAttributedString {
        let attr = AText(self)
            .font(style.font.withSize(style.font.pointSize * fontScale))
            .foregroundColor(textColor)
            .backgroundColor(backgroundColor)
            .attributedString
        
        return underline != nil ? AText.init(attr.string, attributes: attr.attributes(at: 0, effectiveRange: nil)).underline(underline!).attributedString : attr
    }
    
    var isValidEmail: Bool {
        guard !self.lowercased().hasPrefix("mailto:") else { return false }
        guard let emailDetector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) else { return false }
        let matches = emailDetector.matches(in: self, options: NSRegularExpression.MatchingOptions.anchored, range: NSRange(location: 0, length: self.count))
        guard matches.count == 1 else { return false }
        return matches[0].url?.scheme == "mailto"
    }
}
