//
//  MainViewController.swift
//  CovidApp
//
//  Created by jerome on 26/03/2020.
//  Copyright © 2020 Jerome TONNELIER. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    weak var shareDelegate: ShareDelegate? = nil
    weak var coordinatorDelegate: AppCoordinatorDelegate? = nil
    static func create() -> MainViewController {
        return MainViewController.loadFromStoryboard(identifier: "MainViewController", storyboardName: "Main")
    }
    @IBOutlet weak var dashboardLabel: UILabel!
    @IBOutlet weak var noResultView: UIView!
    @IBOutlet weak var noResultLabel: UILabel!
    @IBOutlet weak var launchReportButton: ActionButton!  {
        didSet {
            launchReportButton.actionButtonType = .primary
//            launchReportButton.textColor = Palette.basic.primary.color
            launchReportButton.setTitle("try".local(), for: .normal)
        }
    }

    @IBOutlet weak var reportsCollectionView: UICollectionView!  {
        didSet {
            reportsCollectionView.register(cell: MetricStatesCell.self)
        }
    }

    @IBOutlet weak var friendsCollectionView: UICollectionView!  {
        didSet {
            friendsCollectionView.register(cell: FriendCollectionCell.self)
        }
    }

    @IBOutlet weak var bottomContainerView: UIView!
    
    @IBAction func settingsBUtton(_ sender: Any) {
        coordinatorDelegate?.showSettings()
    }
    
    @IBAction func launchReport(_ sender: Any) {
        coordinatorDelegate?.collectDailyMetrics()
    }
    
    private var noFriendController: NoFriendsViewController!
    private lazy var collectionType: [UICollectionView : CollectionViewType] = [reportsCollectionView : .metrics, friendsCollectionView : .friends]
    let viewModel = MainViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let ctrl = children.compactMap({ $0 as? NoFriendsViewController }).first else {
            fatalError()
        }
        noFriendController = ctrl
        noFriendController.shareDelegate = shareDelegate
        viewModel.shareDelegate = shareDelegate
        handleLayout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadUser()
    }
    
    func loadUser() {
        MessageManager.show(.basic(.loadingPleaseWait), in: self)
        viewModel
            .loadUser { [weak self] in
            guard let self = self else { return }
            // finally update the UI
            self.handleLayout()
        }
    }
    
    private func handleLayout() {
        let numberOfMetrics = viewModel.numberOfItems(in: 0, for: .metrics)
        noResultView.isHidden = numberOfMetrics > 0
        reportsCollectionView.isHidden = numberOfMetrics == 0
        if numberOfMetrics > 0 {
            reportsCollectionView.reloadData()
            reportsCollectionView.layoutIfNeeded()
            reportsCollectionView.scrollToItem(at: IndexPath(row: viewModel.numberOfItems(in: 0, for: collectionType[reportsCollectionView]!) - 1, section: 0), at: .right, animated: false)
        }
        let numberOfFriends = viewModel.numberOfItems(in: 0, for: .friends)
        noFriendController.view.isHidden = numberOfFriends > 0
        friendsCollectionView.isHidden = numberOfFriends == 0
        if numberOfFriends > 0 {
            friendsCollectionView.reloadData()
        }
    }
    
    @IBAction func showSettings(_ sender: Any) {
    }
}

extension MainViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let type = collectionType[collectionView] else { return 0 }
        return viewModel.numberOfItems(in: section, for: type)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let type = collectionType[collectionView] else { return UICollectionViewCell() }
        return viewModel.configureCell(at: indexPath, in: collectionView, for: type)
    }
}

extension MainViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 224, height: 152)
    }
}

extension MainViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.didSelectCell(at: indexPath, for: collectionType[collectionView]!)
    }
}
