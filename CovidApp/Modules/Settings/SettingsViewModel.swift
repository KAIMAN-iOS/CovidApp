//
//  File.swift
//  CovidApp
//
//  Created by jerome on 07/04/2020.
//  Copyright © 2020 Jerome TONNELIER. All rights reserved.
//

import Foundation
import PromiseKit

class SettingsViewModel {
    
    weak var notificationDelegate: DailyNotificationDelegate? = nil
    private var friends: [Friend] = []
    func retrieveFriends() -> Promise<[Friend]> {
        return CovidApi.shared.retrieveFriends()
            .tap {  [weak self] promise in
                guard let self = self else { return }
                switch promise {
                case .fulfilled(let friends): self.friends = friends
                case .rejected: self.friends = []
                }
        }
    }
    
    let notificationHeader = HeaderView.create(with: "Notification".local())
    let friendsHeader = HeaderView.create(with: "friend list".local())
    
    var isTimeCellExpanded: Bool = false
    func didSelectRow(at indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 {
            isTimeCellExpanded.toggle()
            return true
        }
        return false
    }
}

extension SettingsViewModel: TableViewModelable {
    func numberOfSections() -> Int {
        return 2
    }
    
    func numberOfRows(in section: Int) -> Int {
        return section == 0 ? 1 : friends.count
    }
    
    func configureCell(at indexPath: IndexPath, in tableView: UITableView) -> UITableViewCell {
        if indexPath.section == 0 {
            guard let cell: NotificationSettingsCell = tableView.automaticallyDequeueReusableCell(forIndexPath: indexPath) else {
                return UITableViewCell()
            }
            cell.expand = isTimeCellExpanded
            cell.delegate = notificationDelegate
            return cell
        } else {
            guard let cell: FriendSettingsCell = tableView.automaticallyDequeueReusableCell(forIndexPath: indexPath) else {
                return UITableViewCell()
            }
            cell.configure(with: friends[indexPath.row])
            return cell
        }
    }
    
    func header(for section: Int) -> UIView? {
        let view = UIView(frame: CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width, height: heightForHeader(in: section))))
        let header = section == 0 ? notificationHeader : friendsHeader
        view.addSubview(header)
        header.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        return view
    }
    
    func heightForHeader(in section: Int) -> CGFloat {
        return 40
    }
}
