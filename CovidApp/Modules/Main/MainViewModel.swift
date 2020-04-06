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
    func numberOfItems(in section: Int, for type: CollectionViewType) -> Int {
        guard let user = user else { return 0 }
        switch type {
        case .metrics: return user.metrics.count
        case .friends: return user.sharedUsers.count
        }
    }
    
    func configureCell(at indexPath: IndexPath, in collectionView: UICollectionView, for type: CollectionViewType) -> UICollectionViewCell {
        guard let user = user else { return UICollectionViewCell()  }
        switch type {
        case .metrics:
            if let cell: MetricStatesCell = collectionView.automaticallyDequeueReusableCell(forIndexPath: indexPath) {
                cell.configure(user.metrics.reversed()[indexPath.row])
                return cell
            }
            
        case .friends: ()
        }
        return UICollectionViewCell()
    }
    
    private (set) var user: CurrentUser? = nil
    init() {
        user = try? DataManager().retrieve(for: DataManagerKey.currentUser.key)
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
}
