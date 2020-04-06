//
//  UIView+Extensions.swift
//  mtx
//
//  Created by Mikhail Demidov on 10/4/16.
//  Copyright © 2016 Cityway. All rights reserved.
//

import ObjectiveC
import UIKit
import Foundation
import SnapKit


extension UIView {
    
    func addSubview(_ sub: UIView, with insets: UIEdgeInsets = UIEdgeInsets.zero) {
        addSubview(sub)
        sub.translatesAutoresizingMaskIntoConstraints = false
        sub.topAnchor.constraint(equalTo: topAnchor, constant: insets.top).isActive = true
        sub.leftAnchor.constraint(equalTo: leftAnchor, constant: insets.left).isActive = true
        sub.rightAnchor.constraint(equalTo: rightAnchor, constant: insets.right).isActive = true
        sub.bottomAnchor.constraint(equalTo: bottomAnchor, constant: insets.bottom).isActive = true
    }
    
}

extension UIView {
    
    func pop(duration: Double, delay: Double = 0.0, dampingRatio: CGFloat = 0.65) {
        alpha = 0
        transform = CGAffineTransform.init(scaleX: 0.1, y: 0.1)
        let animator = UIViewPropertyAnimator(duration: duration, dampingRatio: dampingRatio) {
            self.alpha = 1
            self.transform = .identity
        }
        animator.startAnimation(afterDelay: delay)
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        set {
            self.layer.cornerRadius = newValue
            self.layer.masksToBounds = true
        }
        get {
            return self.layer.cornerRadius
        }
    }
    
    static func loadFromNib<T: UIView>(name: String? = nil) -> T {
        let nib = name ?? String(describing: T.self)
        return Bundle.main.loadNibNamed(nib, owner: nil, options: nil)!.first! as! T
    }
    
    func findFirstSubview<T: UIView>(withType: T.Type) -> T? {
        if self is T {
            return self as? T
        }
        guard self.subviews.count != 0 else {
            return nil
        }
        for subview in self.subviews {
            let result = subview.findFirstSubview(withType: T.self)
            guard result == nil else {
                return result
            }
        }
        return nil
    }
    
    func asImage() -> UIImage {
        
        // crash when size is 0,0...
        var size = bounds.size
        if size.equalTo(.zero) {
            size = CGSize(width: 1, height: 1)
        }
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        defer {
            UIGraphicsEndImageContext()
        }
        guard let context = UIGraphicsGetCurrentContext() else {
            return UIImage()
        }
        layer.render(in: context)
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            return UIImage()
        }
        return image
    }
    
    func fillWith(view: UIView, at index: Int = 0) {
        insertSubview(view, at: index)
        view.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
}

extension UIView {
    func addShadow(roundCorners: Bool = true, shadowOffset: CGSize = CGSize(width: 0, height: 4), shadowRadius: CGFloat = 4.0, shadowOpacity: Float = 0.2, useMotionEffect: Bool = true) {
        if roundCorners {
            layer.cornerRadius = frame.width / 2
        }
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = shadowOffset
        self.layer.shadowRadius = shadowRadius
        self.layer.shadowOpacity = shadowOpacity
        
        if useMotionEffect == true {
            addShadowMotion()
        }
    }
    
    func addShadowMotion() {
        let horizontalEffect = UIInterpolatingMotionEffect(
            keyPath: "layer.shadowOffset.width",
            type: .tiltAlongHorizontalAxis)
        horizontalEffect.minimumRelativeValue = 16
        horizontalEffect.maximumRelativeValue = -16
        
        let verticalEffect = UIInterpolatingMotionEffect(
            keyPath: "layer.shadowOffset.height",
            type: .tiltAlongVerticalAxis)
        verticalEffect.minimumRelativeValue = 16
        verticalEffect.maximumRelativeValue = -16
        
        let effectGroup = UIMotionEffectGroup()
        effectGroup.motionEffects = [ horizontalEffect,
                                      verticalEffect ]
        
        addMotionEffect(effectGroup)
    }
}


extension UIView {
    
    func addCardBorder(with color: UIColor = UIColor.systemGray) {
        cornerRadius = 10
        layer.borderColor = color.cgColor
        layer.borderWidth = 1.0
    }
    
    func setAsDefaultCard(with color: UIColor = UIColor.lightGray, adddShadow: Bool = true) {
        addCardBorder(with: color)
        clipsToBounds = false
        if adddShadow {
            addShadow(roundCorners: false, shadowOffset: .zero, shadowOpacity: 0.25, useMotionEffect: true)
        }
    }
    
    func round(corners: UIRectCorner,
               cornerRadii: CGSize = CGSize(width: 5, height: 5),
               borderWidth: CGFloat? = nil,
               borderColor: CGColor? = nil,
               strokeStart: CGFloat = 0,
               strokeEnd: CGFloat = 1.0) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: cornerRadii)
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
        
        if let width = borderWidth, let color = borderColor {
            let borderLayer = CAShapeLayer()
            borderLayer.path = mask.path // Reuse the Bezier path
            borderLayer.fillColor = UIColor.clear.cgColor
            borderLayer.strokeColor = color
            borderLayer.lineWidth = width
            borderLayer.frame = self.bounds
            borderLayer.strokeStart = strokeStart
            borderLayer.strokeEnd = strokeEnd
            self.layer.addSublayer(borderLayer)
        }
    }
    
    func setRoundedCorners(corners:UIRectCorner, radius: CGFloat) {
        let rect: CGRect = self.bounds;
        
        // Create the path
        let maskPath: UIBezierPath = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        
        // Create the shape layer and set its path
        let maskLayer: CAShapeLayer = CAShapeLayer()
        maskLayer.frame = rect;
        maskLayer.path = maskPath.cgPath;
        
        // Set the newly created shape layer as the mask for the view's layer
        self.layer.mask = maskLayer;
    }
}

class DottedView: UIView {
    var lineWidth: CGFloat = 8.0
    var dotColor: UIColor = UIColor.red
    
    enum Orientation {
        case vertical, horizontal
        
        func startPoint(in view: UIView) -> CGPoint {
            switch self {
            case .vertical:
                return CGPoint(x:view.frame.midX, y:0)
            case .horizontal:
                return CGPoint(x:0, y:view.frame.midY)
            }
        }
        
        func endPoint(in view: UIView) -> CGPoint {
            switch self {
            case .vertical:
                return CGPoint(x:view.frame.midX, y:view.frame.maxY)
            case .horizontal:
                return CGPoint(x:view.frame.maxX, y:view.frame.midY)
            }
        }
    }
    var orientation: Orientation = .horizontal
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let path = UIBezierPath()
        path.move(to: orientation.startPoint(in: self))
        path.addLine(to: orientation.endPoint(in: self))
        path.lineWidth = lineWidth
        
        let dashes: [CGFloat] = [0.0001, path.lineWidth * 2]
        path.setLineDash(dashes, count: dashes.count, phase: 0)
        path.lineCapStyle = CGLineCap.round
        
        //        UIGraphicsBeginImageContextWithOptions(CGSize(width:300, height:20), false, 2)
        
        UIColor.white.setFill()
        UIGraphicsGetCurrentContext()!.fill(.infinite)
        dotColor.setStroke()
        path.stroke()
        //PlaygroundPage.current.liveView = view
        
        //        UIGraphicsEndImageContext()
    }
}

protocol ViewRoundable {
    var roundedCorners: Bool { get set}
    var borderColor:UIColor? { get set}
}

extension UIView: ViewRoundable {
    var roundedCorners: Bool {
        get {
            return layer.cornerRadius > 0
        }
        
        set (val) {
            DispatchQueue.main.async { [weak self] in
                self?.clipsToBounds = true
                self?.layer.cornerRadius = val ? min(self?.frame.width ?? 0, self?.frame.height ?? 0) / 2.0 : 0
                self?.setNeedsLayout()
            }
        }
    }
    
    var borderColor:UIColor? {
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        
        set (val) {
            layer.borderWidth = val != nil ? 2.0 : 0
            layer.borderColor = val?.cgColor
            setNeedsLayout()
            //            DispatchQueue.main.async { [weak self] in
            //                self?.setNeedsLayout()
            //            }
        }
    }
    
}


extension UIView {
    
    /**
     Rounds the given set of corners to the specified radius
     
     - parameter corners: Corners to round
     - parameter radius:  Radius to round to
     */
    func round(corners: UIRectCorner, radius: CGFloat) {
        _ = _round(corners: corners, radius: radius)
    }
    
    /**
     Rounds the given set of corners to the specified radius with a border
     
     - parameter corners:     Corners to round
     - parameter radius:      Radius to round to
     - parameter borderColor: The border color
     - parameter borderWidth: The border width
     */
    func round(corners: UIRectCorner, radius: CGFloat, borderColor: UIColor, borderWidth: CGFloat) {
        let mask = _round(corners: corners, radius: radius)
        addBorder(mask: mask, borderColor: borderColor, borderWidth: borderWidth)
    }
    
    /**
     Fully rounds an autolayout view (e.g. one with no known frame) with the given diameter and border
     
     - parameter diameter:    The view's diameter
     - parameter borderColor: The border color
     - parameter borderWidth: The border width
     */
    func fullyRound(diameter: CGFloat, borderColor: UIColor, borderWidth: CGFloat) {
        layer.masksToBounds = true
        layer.cornerRadius = diameter / 2
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor.cgColor;
    }
    
}

private extension UIView {
    
    @discardableResult func _round(corners: UIRectCorner, radius: CGFloat) -> CAShapeLayer {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
        return mask
    }
    
    func addBorder(mask: CAShapeLayer, borderColor: UIColor, borderWidth: CGFloat) {
        let borderLayer = CAShapeLayer()
        borderLayer.path = mask.path
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = borderColor.cgColor
        borderLayer.lineWidth = borderWidth
        borderLayer.frame = bounds
        layer.addSublayer(borderLayer)
    }
    
}


extension UIView {
    
    @discardableResult
    func anchor(top: NSLayoutYAxisAnchor? = nil, left: NSLayoutXAxisAnchor? = nil, bottom: NSLayoutYAxisAnchor? = nil, right: NSLayoutXAxisAnchor? = nil, paddingTop: CGFloat = 0, paddingLeft: CGFloat = 0, paddingBottom: CGFloat = 0, paddingRight: CGFloat = 0, width: CGFloat = 0, height: CGFloat = 0) -> [NSLayoutConstraint] {
        translatesAutoresizingMaskIntoConstraints = false
        
        var anchors = [NSLayoutConstraint]()
        
        if let top = top {
            anchors.append(topAnchor.constraint(equalTo: top, constant: paddingTop))
        }
        if let left = left {
            anchors.append(leftAnchor.constraint(equalTo: left, constant: paddingLeft))
        }
        if let bottom = bottom {
            anchors.append(bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom))
        }
        if let right = right {
            anchors.append(rightAnchor.constraint(equalTo: right, constant: -paddingRight))
        }
        if width > 0 {
            anchors.append(widthAnchor.constraint(equalToConstant: width))
        }
        if height > 0 {
            anchors.append(heightAnchor.constraint(equalToConstant: height))
        }
        
        anchors.forEach({$0.isActive = true})
        
        return anchors
    }
    
    @discardableResult
    func anchorToSuperview() -> [NSLayoutConstraint] {
        return anchor(top: superview?.topAnchor, left: superview?.leftAnchor, bottom: superview?.bottomAnchor, right: superview?.rightAnchor)
    }
}

extension UIView {
    
    class func autolayout() -> Self {
        let view = self.init()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    @discardableResult func autolayout() -> Self {
        self.translatesAutoresizingMaskIntoConstraints = false
        return self
    }
    
    @discardableResult func add(in superView: UIView) -> Self {
        superView.addSubview(self)
        return self
    }
    
    @discardableResult func layout(constraints: (ConstraintMaker) -> Void) -> Self {
        self.snp.makeConstraints(constraints)
        self.translatesAutoresizingMaskIntoConstraints = false
        return self
    }
    
    @discardableResult func updateLayout(constraints: (ConstraintMaker) -> Void) -> Self {
        self.snp.updateConstraints(constraints)
        self.translatesAutoresizingMaskIntoConstraints = false
        return self
    }
    
    @discardableResult func remakeLayout(constraints: (ConstraintMaker) -> Void) -> Self {
        self.snp.remakeConstraints(constraints)
        self.translatesAutoresizingMaskIntoConstraints = false
        return self
    }
    
    func add(constraints: String, for views: [String: UIView]) {
        
        for (_,view) in views {
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: constraints, options: [], metrics: nil, views: views))
    }
    
    func printSubviews(at index:Int = 0) {
        let tab = Array<String>(repeating: "--", count: index)
        print("\(tab.joined())-> \(self is UILabel) - \(self)")
        subviews.forEach { (subview) in
            subview.printSubviews(at: index + 1)
        }
    }
    
    func updateConstraints(animated: Bool = true, duration: Double = 0.5, useSpringWithDamping damping: CGFloat = 0.5, initialVelocity valocity: CGFloat = 0.5, _ animationBlock: @escaping (() -> Void)) {
        guard animated == true else {
            animationBlock()
            return
        }
        
        let animator = UIViewPropertyAnimator(duration: duration, dampingRatio: damping, animations: animationBlock)
        layoutIfNeeded()
        animator.startAnimation()
    }
}

extension UIStackView {
    func clear(from: Int = 0, to: Int? = nil) {
        arrangedSubviews[from..<(to == nil ? arrangedSubviews.count : to!)].forEach { (view) in
            removeArrangedSubview(view)
            view.removeFromSuperview()
        }
    }
}
