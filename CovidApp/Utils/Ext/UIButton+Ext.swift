//
//  UIButton+Ext.swift
//  CovidApp
//
//  Created by jerome on 28/03/2020.
//  Copyright © 2020 Jerome TONNELIER. All rights reserved.
//

import UIKit

extension UIButton {
    enum LayoutType {
        case primary
        case inverted
    }
}

class Button: UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        switch layoutType {
        case .primary:
            layer.cornerRadius = bounds.height / 2.0
            backgroundColor = Palette.basic.primary.color
            setTitleColor(.white, for: .normal)
            
        case .inverted:
            layer.cornerRadius = bounds.height / 2.0
            backgroundColor = UIColor.white
            setTitleColor(Palette.basic.primary.color, for: .normal)
            setTitle(title(for: .normal), for: .normal)
        }
    }
    
    var layoutType: UIButton.LayoutType = .primary
    func configure(with layoutType: UIButton.LayoutType) {
        self.layoutType = layoutType
    }
}
