//
//  ActionButton.swift
//  Moovizy
//
//  Created by jerome on 06/04/2018.
//  Copyright © 2018 CITYWAY. All rights reserved.
//

import UIKit
import NSAttributedStringBuilder

enum ActionButtonType {
    
    case primary
    case secondary
    case connection(type: ConnectionType)
    case smoked
    case alert
    case loading
    case animated
    case swipeCardButton(isYesButton: Bool)
    
    enum ConnectionType {
        case facebook
        case google
//        case apple
        
        var image: UIImage? {
            switch self {
            case .facebook: return UIImage(named: "facebook")
            case .google: return UIImage(named: "google")
//            case .apple: return UIImage(named: "apple")
            }
        }
        
        var title: String {
            switch self {
            case .facebook: return "Connect with facebook".local()
            case .google: return "Connect with google".local()
            }
        }
    }
    
    
    var strokeColor: UIColor? {
        switch self {
        case .secondary: return Palette.basic.lightGray.color
        case .primary: return Palette.basic.primary.color
        default: return nil
        }
    }
    
    var strokeWidth: CGFloat {
        switch self {
        case .secondary:
            return 2.0
        default:
            return 0
        }
    }
    
    var textColor: UIColor? {
        switch self {
        case .secondary: return Palette.basic.primary.color
        case .animated: return Palette.basic.mainTexts.color
        case .loading: return UIColor.white.withAlphaComponent(0.7)
        case .alert: return .white
        default: return .white
        }
    }
    
    var shadowColor: UIColor? {
        switch self {
        case .connection: return UIColor.black
        default: return nil
        }
    }
    
    var fontType: FontType {
        switch self {
        default: return .button
        }
    }
    
    var textShadowColor: UIColor? {
        switch self {
        default: return nil
        }
    }
    
    var mainColor: UIColor? {
        switch self {
        case .primary: return Palette.basic.primary.color
        case .secondary: return .white
        case .connection: return Palette.basic.primary.color
        case .smoked: return Palette.basic.lightGray.color
        case .alert: return Palette.basic.alert.color
        case .loading: return Palette.basic.primary.color
        case .animated: return .white
        case .swipeCardButton(let isYesButton): return isYesButton ? Palette.basic.alert.color : Palette.basic.confirmation.color
        }
    }
    
    func updateBackground(for button: UIButton) {
        button.setBackgroundImage(nil, for: .normal)
        
        switch self {
        case .primary:
            button.backgroundColor = Palette.basic.primary.color
            
        case .secondary:
            button.backgroundColor = .white
            
        case .connection(let type):
            switch type {
            case .facebook: button.backgroundColor = UIColor.init(hexString: "#3b5998")
            case .google: button.backgroundColor = UIColor.init(hexString: "#DB4437")
            }
            button.setImage(type.image, for: .normal)
            button.setTitle(type.title, for: .normal)
            
        case .smoked:
            button.backgroundColor = mainColor
            
        case .alert:
            button.backgroundColor = Palette.basic.alert.color
            
        case .loading:
            button.backgroundColor = UIColor.white.withAlphaComponent(0.15)
            
        case .animated:
            button.backgroundColor = .white
            
        case .swipeCardButton(let isYesButton): button.backgroundColor = isYesButton ? Palette.basic.alert.color : Palette.basic.confirmation.color
        }
    }
}

extension ActionButtonType: Equatable {}
func == (lhs: ActionButtonType, rhs: ActionButtonType) -> Bool {
    switch (lhs, rhs) {
    case (.secondary, .secondary): return true
    case (.smoked, .smoked): return true
    case (.connection(let lhsType), .connection(let rhsType)):
        switch (lhsType, rhsType) {
        case (.facebook, .facebook): return true
        case (.google, .google): return true
        default: return false
        }
    default: return false
    }
}

typealias ActionButtonConfigurationData = (type: ActionButtonType, title: String, completion: (() -> Void)?)

class ActionButton: UIButton {
    
    override var isEnabled: Bool  {
        didSet {
            DispatchQueue.main.async {
                if self.isEnabled {
                    // have to use a variable to be able to assign variable to itself :-/
                    self.updateButton(for: self.actionButtonType)
                } else {
                    self.updateButton(for: .smoked)
                }
            }
        }
    }
    
    private var _savedTitle: String?
    var isLoading: Bool = false {
        didSet {
            if isLoading == false, loader.superview != nil {
                setTitle(_savedTitle, for: .normal)
                // have to use a variable to be able to assign variable to itself :-/
                updateButton(for: actionButtonType)
            } else if loader.superview == nil, isLoading == true {
                _savedTitle = titleLabel?.text
                setTitle(" ", for: .normal)
                updateButton(for: .loading)
            }
        }
    }

    var textColor: UIColor? {
        get {
            if let textColor = self._textColor {
                return textColor
            }
            return actionButtonType.textColor
        }
        set {
            self._textColor = newValue
            self.updateText()
        }
    }
    private var _textColor: UIColor?
    
    private lazy var loader: UIActivityIndicatorView = {
        $0.hidesWhenStopped = true
        $0.color = self.actionButtonType.mainColor
        return $0
    } (UIActivityIndicatorView(style: .white))

    private func updateText() {
        if let attributedTitle = self.attributedTitle(for: .normal) {
            self.setTitle(attributedTitle.string, for: .normal)
            return
        }
        
        if let title = self.title(for: .normal) {
            self.setTitle(title, for: .normal)
            return
        }
    }
    
    var actionButtonType: ActionButtonType = .primary {
        didSet {
            if isEnabled {
                // have to use a variable to be able to assign variable to itself :-/
                updateButton(for: actionButtonType)
            } else {
                updateButton(for: .smoked)
            }
        }
    }
    
    // update the button's layout for a given type without changing its initial actionButtonType
    private func updateButton(for type: ActionButtonType) {
        
        if loader.superview != nil {
            loader.removeFromSuperview()
            loader.stopAnimating()
            layoutIfNeeded()
        }
        
        titleLabel?.typeObserver = true
        titleLabel?.minimumScaleFactor = 0.5
        titleLabel?.adjustsFontSizeToFitWidth = true
        clipsToBounds = false
        type.updateBackground(for: self)
        layer.borderColor = type.strokeColor?.cgColor
        layer.borderWidth = type.strokeWidth
        if let shadowColor = type.shadowColor {
            layer.shadowColor = shadowColor.cgColor
            layer.shadowRadius = 5
            layer.shadowOpacity = 0.5
            layer.shadowOffset = .zero
        }
        titleEdgeInsets = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)//.zero
        
        switch type {
        case .connection:
            contentEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 12)
            titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
            imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
            contentHorizontalAlignment = .center
            
        case .loading:
            addSubview(loader)
            loader.startAnimating()
            loader.snp.makeConstraints { make in
                make.center.equalToSuperview()
            }
        
        default:
            contentEdgeInsets = .zero
            titleEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)//.zero
            contentHorizontalAlignment = .center
        }
        
        layoutSubviews()
    }

    
    init(frame: CGRect, type: ActionButtonType = .primary) {
        defer {
            actionButtonType = type
        }
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        actionButtonType = .primary
    }

    override func setTitle(_ title: String?, for state: UIControl.State) {
        self.setTitle(title, for: state, with: nil)
    }

    func setTitle(_ title: String?, for state: UIControl.State, with color: UIColor?) {
        super.setAttributedTitle(attributedString(for: title, with: color), for: state)
    }
    
    private func attributedString(for title: String?, with color: UIColor?) -> NSAttributedString? {
        var attr: NSAttributedString!
        switch actionButtonType {
        default:
            attr = title?.asAttributedString(for: actionButtonType.fontType, textColor: (color ?? actionButtonType.textColor) ?? .black)
        }
        if let shadowColor = actionButtonType.textShadowColor {
            attr = AText.init(attr.string, attributes: attr.attributes(at: 0, effectiveRange: nil)).shadow(color: shadowColor, radius: 5.0, x: 2, y: 2).attributedString
        }
        return attr
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        Constants.defaultComponentShape.applyShape(on: self)
    }
    
}
