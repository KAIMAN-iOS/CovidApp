//
//  UIFont+Extension.swift
//  Moovizy
//
//  Created by jerome on 06/04/2018.
//  Copyright © 2018 CITYWAY. All rights reserved.
//

import UIKit
//
//  Fonts.swift
//  mtx
//
//  Created by Demidov Mikhail on 10/31/16.
//  Copyright © 2016 Cityway. All rights reserved.
//

import UIKit

struct Font {
    
    private init() { }
    
    enum TextStyle {
        case title1
        case title2
        case title3
        case headline
        case subheadline
        case body
        case callout
        case footnote
        case caption1
        case caption2
        
        var value: UIFont.TextStyle {
            switch self {
            case .title1: return UIFont.TextStyle.title1
            case .title2: return UIFont.TextStyle.title2
            case .title3: return UIFont.TextStyle.title3
            case .headline: return UIFont.TextStyle.headline
            case .subheadline: return UIFont.TextStyle.subheadline
            case .body: return UIFont.TextStyle.body
            case .callout: return UIFont.TextStyle.callout
            case .footnote: return UIFont.TextStyle.footnote
            case .caption1: return UIFont.TextStyle.caption1
            case .caption2: return UIFont.TextStyle.caption2
            }
        }
    }
    
    static func style(_ style: TextStyle) -> UIFont {
        return UIFont.preferredFont(forTextStyle: style.value)
    }
    
    
}

extension UIFont {
    
    func withTraits(traits:UIFontDescriptor.SymbolicTraits...) -> UIFont {
        let descriptor = self.fontDescriptor.withSymbolicTraits(UIFontDescriptor.SymbolicTraits(traits))
        return UIFont(descriptor: descriptor!, size: 0)
    }
    
    func bold() -> UIFont {
        return withTraits(traits: .traitBold)
    }
    
    func italic() -> UIFont {
        return withTraits(traits: .traitItalic)
    }
    
    func boldItalic() -> UIFont {
        return withTraits(traits: .traitBold, .traitItalic)
    }
    
}


let textStyles:[UIFont.TextStyle] = [.title1,
                                    .headline,
                                    .subheadline,
                                    .body,
                                    .footnote,
                                    .caption2]


// Dynamic Type change handler
// Adopt this on controls to adapt to Dynamic Type changes
protocol DynamicTypeChangeHandler {
    
    var typeObserver: Bool {get set}
}

extension UILabel : DynamicTypeChangeHandler {
    
    @IBInspectable var typeObserver: Bool {
        
        get {
            return DynamicTypeManager.shared.isControlRegistered(control: self)
        }
        
        set {
            DynamicTypeManager.shared.registerControl(control: self, fontKeyPath: "font")
        }
    }
}


extension UIButton : DynamicTypeChangeHandler {
    
    @IBInspectable var typeObserver: Bool {
        
        get {
            return DynamicTypeManager.shared.isControlRegistered(control: self)
        }
        
        set {            
            DynamicTypeManager.shared.registerControl(control: self, fontKeyPath: "titleLabel?.font")
        }
    }
    
}

extension UITextField : DynamicTypeChangeHandler {
    
    @IBInspectable var typeObserver: Bool {
        
        get {
            return DynamicTypeManager.shared.isControlRegistered(control: self)
        }
        
        set {
            DynamicTypeManager.shared.registerControl(control: self, fontKeyPath: "font")
        }
    }
}

extension UISegmentedControl: DynamicTypeChangeHandler {
    
    @IBInspectable var typeObserver: Bool {
        
        get {
            return DynamicTypeManager.shared.isControlRegistered(control: self)
        }
        
        set {
            
            let currentAttributes = self.titleTextAttributes(for: .normal)
            DynamicTypeManager.shared.registerControl(control: self, font: currentAttributes?[NSAttributedString.Key.font] as! UIFont) { (fontStyle) -> () in
                
                let changedAttributes = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: UIFont.TextStyle(rawValue: fontStyle))]
                self.setTitleTextAttributes(changedAttributes, for: .normal)
            }
        }
    }
}


extension UITextView: DynamicTypeChangeHandler {
    
    @IBInspectable var typeObserver: Bool {
        
        get {
            return DynamicTypeManager.shared.isControlRegistered(control: self)
        }
        
        set {
            DynamicTypeManager.shared.registerControl(control: self, fontKeyPath: "font")
        }
    }
    
}


// Dynamic Type Text Styles


// Contains the font key path and style
class DynamicTypeControlValues: NSObject {
    
    var fontKeyPath: String?
    var fontStyle: String
    var closure: ((_ fontStyle: String) -> ())?
    
    init(fontKeyPath: String, fontStyle: String) {
        self.fontKeyPath = fontKeyPath
        self.fontStyle = fontStyle
    }
    
    init(style: String, closure:@escaping (_ fontStyle: String) -> ()) {
        self.fontStyle = style
        self.closure = closure
    }
    
}


internal class DynamicTypeManager {
    
    // Dynamic Type Manager (Singleton)
    static let dynamicTypeManager = DynamicTypeManager()
    
    // Reference to the DynamicTypeManager shared instance
    class var shared: DynamicTypeManager {
        return dynamicTypeManager
    }
    
    // Map table holds a weak reference to registered controls
    var registeredElements: NSMapTable<AnyObject, AnyObject>
    
    init () {
        
        self.registeredElements = NSMapTable.weakToStrongObjects()
        
        // Register the Dynamic Type Manager for Dynamic Type Change notifications
        NotificationCenter.default.addObserver(forName: UIContentSizeCategory.didChangeNotification, object: nil, queue: nil) { (note) -> Void in
            
            let registeredElements = self.registeredElements
            
            for (element) in registeredElements.keyEnumerator() {
                
                guard let control = element as? UIView else { return }
                guard let controlValues = registeredElements.object(forKey: control) as? DynamicTypeControlValues else { return }
                
                
                if let closure = controlValues.closure {
                    closure(controlValues.fontStyle)
                }else{
                    
                    if let keyPath = controlValues.fontKeyPath {
                        control.setValue(UIFont.preferredFont(forTextStyle: UIFont.TextStyle(rawValue: controlValues.fontStyle)),
                                         forKeyPath: keyPath)
                    }else {
                        // Woops
                    }
                    
                }
                
                // Resize the control to fit
                control.sizeToFit()
                
            }
        }
    }
    
    // Register a UI control
    func registerControl(control: UIView, fontKeyPath: String) {
        
        // Get the control's current font and derive it's style
        guard let font = control.value(forKeyPath: fontKeyPath) as? UIFont else { return }
        guard let fontStyle = self.fontStyleFor(font, view: control) else { return }
        // Register the control along with its font keypath and font style
        self.registeredElements.setObject(DynamicTypeControlValues(fontKeyPath: fontKeyPath, fontStyle: fontStyle as String),
                                          forKey: control)
        
    }
    
    // Register a UI control with a closure for callback
    func registerControl(control: UIView, font: UIFont, withClosure:@escaping (_ fontStyle: String) -> ()) {
        
        guard let fontStyle = fontStyleFor(font, view: control) else { return }
        // Register the control along with its font style
        self.registeredElements.setObject(DynamicTypeControlValues(style: fontStyle, closure: withClosure), forKey: control)
        
    }
    
    // Returns true if the specified control is registered
    func isControlRegistered(control: UIView) -> Bool {
        return self.registeredElements.object(forKey: control) != nil
    }
    
    // Returns the font style for the specified font
    func fontStyleFor(_ font: UIFont, view: UIView) -> String? {
        
        var fontStyle: String?
        
        for style in textStyles {
            if font.isEqual(UIFont.preferredFont(forTextStyle: style)) {
                fontStyle = style.rawValue
                break
            }
        }
        
        guard let _ = fontStyle else {
//            print("/!\\ [ACCESSIBILITY ERROR] You must specify a style rather than a specific font type for control: \n \(view)")
            return nil
        }
        
        return fontStyle
    }
    
    deinit {
        // Remove the Dynamic Type Manager from notifications
        NotificationCenter.default.removeObserver(self)
    }
}
