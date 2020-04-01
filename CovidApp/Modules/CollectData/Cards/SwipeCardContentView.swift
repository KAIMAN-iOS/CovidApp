//
//  SwipeCardContentView.swift
//  CovidApp
//
//  Created by jerome on 26/03/2020.
//  Copyright © 2020 Jerome TONNELIER. All rights reserved.
//

import UIKit

class SwipeCardContentView: UIView {

    @IBOutlet weak var card: UIView!  {
        didSet {
            card.setAsDefaultCard()
        }
    }

    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var text: UILabel!
    
    func configure(with metric: MetricType) {
        icon.image = metric.icon
        text.set(text: metric.text, for: .title)
    }

}
