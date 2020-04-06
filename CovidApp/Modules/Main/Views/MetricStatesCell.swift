//
//  MetricStatesCell.swift
//  CovidApp
//
//  Created by jerome on 30/03/2020.
//  Copyright © 2020 Jerome TONNELIER. All rights reserved.
//

import UIKit
import SwiftDate

class MetricStatesCell: UICollectionViewCell {

    @IBOutlet weak var card: UIView!  {
        didSet {
            card.setAsDefaultCard()
        }
    }

    @IBOutlet weak var stackView: UIStackView!
    
    func configure(_ metric: Metrics) {
        stackView.clear()
        addStackView(forMetricsAt: (0...2), in: metric)
        addStackView(forMetricsAt: (3...4), in: metric, includeDate: true)
        invalidateIntrinsicContentSize()
        layoutIfNeeded()
    }
    
    func addStackView(forMetricsAt indexes: ClosedRange<Int>, in metrics: Metrics, includeDate: Bool = false) {
        let stackView = UIStackView()
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.spacing = 0
        metrics.metrics[indexes].forEach { metric in
            stackView.addArrangedSubview(metricView(for: metric))
        }
        if includeDate {
            stackView.addArrangedSubview(metricView(for: metrics.date))
        }
        self.stackView.addArrangedSubview(stackView)
    }
    
    private func metricView(for type: Metric) -> MetricStateView {
        let view: MetricStateView = MetricStateView.loadFromNib()
        view.configure(with: type)
        return view
    }
    
    private func metricView(for date: Date) -> MetricStateView {
        let view: MetricStateView = MetricStateView.loadFromNib()
        view.configure(with: date)
        return view
    }
}
