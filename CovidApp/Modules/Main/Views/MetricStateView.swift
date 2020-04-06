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
            backgroundView.roundedCorners = true
        }
    }

    @IBOutlet weak var metricsIcon: UIImageView!
    @IBOutlet weak var dateContainer: UIView!
    @IBOutlet weak var day: UILabel!
    @IBOutlet weak var month: UILabel!
    
    func configure(with metricState: Metric) {
        backgroundView.backgroundColor = .clear
        backgroundView.layer.borderColor = metricState.color.cgColor
        backgroundView.layer.borderWidth = 2
        metricsIcon.tintColor = metricState.color
        metricsIcon.image = metricState.metric.metricIcon
        dateContainer.isHidden = true
    }
    
    func configure(with date: Date) {
        let compo = Calendar.current.dateComponents([.day, .month], from: date)
        day.text = String(format: "%0.2d", compo.day!)
        month.text = String(format: "%0.2d", compo.month!)
        metricsIcon.isHidden = true
        backgroundView.backgroundColor = Palette.basic.primary.color
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundView.cornerRadius = backgroundView.bounds.midY
    }
}
