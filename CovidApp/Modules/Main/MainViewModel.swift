//
//  MainViewModel.swift
//  CovidApp
//
//  Created by jerome on 30/03/2020.
//  Copyright © 2020 Jerome TONNELIER. All rights reserved.
//

import Foundation

enum CollectionViewType {
    case metrics, friends
}

class MainViewModel {
    weak var shareDelegate: ShareDelegate? = nil
    weak var coordinatorDelegate: AppCoordinatorDelegate? = nil
    func numberOfItems(in section: Int, for type: CollectionViewType) -> Int {
        guard let user = user else { return 0 }
        switch type {
        case .metrics: return metrics.count
        case .friends: return user.sharedUsers.count > 0 ? user.sharedUsers.count + 1 : 0
        }
    }
    
    func configureCell(at indexPath: IndexPath, in collectionView: UICollectionView, for type: CollectionViewType) -> UICollectionViewCell {
        guard let user = user else { return UICollectionViewCell()  }
        switch type {
        case .metrics:
            if let cell: MetricStatesCell = collectionView.automaticallyDequeueReusableCell(forIndexPath: indexPath) {
                cell.configure(metrics[indexPath.row])
                return cell
            }
            
        case .friends:
            if let cell: FriendCollectionCell = collectionView.automaticallyDequeueReusableCell(forIndexPath: indexPath) {
                cell.configure(with:  indexPath.row == user.sharedUsers.count ? .add : .friend(user.sharedUsers[indexPath.row]))
                return cell
            }
        }
        return UICollectionViewCell()
    }
    
    private (set) var user: CurrentUser? = nil
    private var metrics: [Metrics] = []
    init() {
        user = try? DataManager().retrieve(for: DataManagerKey.currentUser.key)
        metrics = user?.user.metrics.sorted(by: { $0.date < $1.date }) ?? []
    }
    
    func loadUser(completion: @escaping (() -> Void)) {
        if SessionController().userLoggedIn == true {
            CovidApi.shared.retrieveUser().done { [weak self] user in
                guard let self = self else { return }
                self.user = user
                completion()
            }.catch { error in
                //TODO: Handle th error
            }
        } else {
            completion()
        }
    }
    
    func didSelectCell(at indexPath: IndexPath, for type: CollectionViewType) {
        switch type {
        case .friends:
            if indexPath.row == user?.sharedUsers.count {
                shareDelegate?.share(from: nil)
            } else {
                coordinatorDelegate?.showMetricsDetail(for: user!.sharedUsers[indexPath.row])
            }
            
        default: ()
        }
    }
}
