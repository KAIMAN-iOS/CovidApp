//
//  MetricsCollectionViewController.swift
//  CovidApp
//
//  Created by jerome on 08/04/2020.
//  Copyright © 2020 Jerome TONNELIER. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class MetricsCollectionViewController: UICollectionViewController {

    private var user: User!
    private var viewModel: MetricsCollectionViewModel!
    static func create(with user: User) -> MetricsCollectionViewController {
        let ctrl = MetricsCollectionViewController.loadFromStoryboard(identifier: "MetricsCollectionViewController", storyboardName: "Main") as! MetricsCollectionViewController
        ctrl.user = user
        ctrl.viewModel = MetricsCollectionViewModel(user: user)
        return ctrl
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: true)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView.register(cell: MetricStatesCell.self)

        // Do any additional setup after loading the view.
    }

    // MARK: UICollectionViewDataSource
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return viewModel.numberOfItems()
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return viewModel.configureCell(at: indexPath, in: collectionView)
    }
}
