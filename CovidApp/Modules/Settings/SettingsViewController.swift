//
//  SettingsViewController.swift
//  CovidApp
//
//  Created by jerome on 06/04/2020.
//  Copyright © 2020 Jerome TONNELIER. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    weak var shareDelegate: ShareDelegate? = nil
    weak var notificationDelegate: DailyNotificationDelegate? = nil
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    static func createNavigationStack() -> UINavigationController {
        let nav = UINavigationController.loadFromStoryboard(identifier: "SettingsNavigationController", storyboardName: "Main") as! UINavigationController
        return nav
//        return SettingsViewController.loadFromStoryboard(identifier: "SettingsViewController", storyboardName: "Main")
    }
    @IBOutlet weak var tableView: UITableView!  {
        didSet {
            tableView.commonInit()
        }
    }
    weak var closeDelegate: CloseDelegate? = nil

    let viewModel = SettingsViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "settings".local()
        viewModel.notificationDelegate = notificationDelegate
        viewModel.deleteFriendDelegate = self
        retrieveFriends()
        backgroundView.shareDelegate = self
    }
    
    let backgroundView: NoFriendsViewController = NoFriendsViewController.create()
    private func retrieveFriends() {
        activityIndicator.startAnimating()
        viewModel.retrieveFriends()
            .ensure { [weak self] in
                self?.activityIndicator.stopAnimating()
        }
        .done { [weak self] friends in
            guard let self = self else { return }
            guard friends.count > 0 else {
                self.tableView.backgroundView = self.backgroundView.view
                return
            }
            self.tableView.backgroundView = nil
            self.tableView.reloadData()
        }.catch { error in
            MessageManager.show(.request(.serverError))
            self.tableView.backgroundView = self.backgroundView.view
        }
    }
    
    @IBAction func close(_ sender: Any) {
        closeDelegate?.close(self)
    }
}


//MARK: UITableViewDelegate
extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if viewModel.didSelectRow(at: indexPath) {
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return viewModel.heightForHeader(in: section)
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return viewModel.header(for: section)
    }
}

//MARK: UITableViewDataSource
extension SettingsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows(in: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return viewModel.configureCell(at: indexPath, in: tableView)
    }
}

extension SettingsViewController: DeleteFriendDelegate {
    func deleteFriend(with id: Int) {
        let alert = UIAlertController(title: "Attention".local(), message: "About to Delete friend".local(), preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "confirm delete".local(), style: .destructive, handler: { [weak self] _ in
//            self?.dismiss(animated: true, completion: nil)
            self?.activityIndicator.startAnimating()
            self?.viewModel.deleteFriend(with: id).done { [weak self] _ in
                self?.retrieveFriends()
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel".local(), style: .cancel, handler: { [weak self] _ in
//            self?.dismiss(animated: true, completion: nil)
        }))
        
        present(alert, animated: true, completion: nil)
    }
}

extension SettingsViewController: ShareDelegate {
    func share(from controller: UIViewController?) {
        shareDelegate?.share(from: self)
    }
}

