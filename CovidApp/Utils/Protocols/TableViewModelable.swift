//
//  File.swift
//  FindABox
//
//  Created by jerome on 16/09/2019.
//  Copyright © 2019 Jerome TONNELIER. All rights reserved.
//

import UIKit

protocol TableViewModelable {
    func numberOfRows(in section: Int) -> Int
    func numberOfRows() -> Int
    func numberOfSections() -> Int
    func header(for section: Int) -> UIView?
    func heightForHeader(in section: Int) -> CGFloat
    func configureCell(at indexPath: IndexPath, in tableView: UITableView) -> UITableViewCell
}

extension TableViewModelable {
    func numberOfRows(in section: Int) -> Int {
        return 0
    }
    
    func numberOfRows() -> Int {
        return numberOfRows(in: 0)
    }
    
    func numberOfSections() -> Int {
        return 1
    }
    
    func header(for section: Int) -> UIView? {
        return nil
    }
    
    func heightForHeader(in section: Int) -> CGFloat {
        return 0
    }
    
    func configureCell(at indexPath: IndexPath, in tableView: UITableView) -> UITableViewCell {
        return UITableViewCell()
    }
}
