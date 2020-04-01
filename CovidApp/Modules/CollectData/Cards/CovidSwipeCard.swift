//
//  CovidSwipeCard.swift
//  CovidApp
//
//  Created by jerome on 26/03/2020.
//  Copyright © 2020 Jerome TONNELIER. All rights reserved.
//

import UIKit
import Shuffle

private class ConfirmOverlay: UIView {
    
    private static func confirmOverlaywith(imageNamed imageName: String, tintColor: UIColor) -> UIView {
        let overlay = UIView()
        let image = UIImageView(image: UIImage(named: imageName)?.withRenderingMode(.alwaysTemplate))
        image.tintColor = tintColor
        overlay.addSubview(image)
        image.anchor(bottom: overlay.bottomAnchor,
                            right: overlay.centerXAnchor,
                            paddingBottom: 30,
                            paddingRight: -image.bounds.midX)
        return overlay
    }
    
    static func left() -> UIView {
        return ConfirmOverlay.confirmOverlaywith(imageNamed: "no", tintColor: Palette.basic.confirmation.color)
    }
    
    static func right() -> UIView {
        return ConfirmOverlay.confirmOverlaywith(imageNamed: "yes", tintColor: Palette.basic.alert.color)
    }
}

class CovidSwipeCard: SwipeCard {
    override var swipeDirections: [SwipeDirection] {
        return [.left, .right]
    }
    
    private var metric: MetricType
    init(frame: CGRect, metric: MetricType) {
        self.metric = metric
        super.init(frame: frame)
        let swipeView: SwipeCardContentView = SwipeCardContentView.loadFromNib()
        swipeView.configure(with: metric)
        content = swipeView
        footerHeight = 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func overlay(forDirection direction: SwipeDirection) -> UIView? {
        switch direction {
        case .left:
            return ConfirmOverlay.left()
        case.right:
            return ConfirmOverlay.right()
        default:
            return nil
        }
    }
}
