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
    
    func addCardBorder(with color: UIColor = UIColor.systemGray) {
        cornerRadius = 10
        layer.borderColor = color.cgColor
        layer.borderWidth = 1.0
    }
    
    func setAsDefaultCard(with color: UIColor = UIColor.lightGray) {
        addCardBorder(with: color)
        clipsToBounds = false
//        addShadow(roundCorners: false, shadowOffset: .zero, shadowOpacity: 0.25, useMotionEffect: true)
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
