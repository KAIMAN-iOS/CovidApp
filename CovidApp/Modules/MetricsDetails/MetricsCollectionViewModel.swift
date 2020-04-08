//
//  MetricsCollectionViewModel.swift
//  CovidApp
//
//  Created by jerome on 08/04/2020.
//  Copyright © 2020 Jerome TONNELIER. All rights reserved.
//

import UIKit

class MetricsCollectionViewModel {
    let metrics: [Metrics]
    init(user: User) {
        self.metrics = user.metrics
    }
    
    func numberOfItems() -> Int {
        return metrics.count
    }
    
    func configureCell(at indexPath: IndexPath, in collectionView: UICollectionView) -> UICollectionViewCell {
        if let cell: MetricStatesCell = collectionView.automaticallyDequeueReusableCell(forIndexPath: indexPath) {
            cell.configure(metrics[indexPath.row])
            return cell
        }
        return UICollectionViewCell()
    }
}
