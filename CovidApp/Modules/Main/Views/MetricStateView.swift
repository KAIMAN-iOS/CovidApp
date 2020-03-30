//
//  MetricStateView.swift
//  CovidApp
//
//  Created by jerome on 29/03/2020.
//  Copyright © 2020 Jerome TONNELIER. All rights reserved.
//

import UIKit

class MetricStateView: UIView {

    @IBOutlet weak var backgroundView: UIView!  {
        didSet {
//            cornerRadius = 5.0
            backgroundView.setAsDefaultCard()
        }
    }

    @IBOutlet weak var icon: UIImageView!
    
    func configure(with metricState: MetricState) {
        backgroundView.backgroundColor = metricState.color
        icon.image = metricState.metricIcon
    }
}
