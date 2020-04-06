//
//  UITableViewExtension.swift
//  1001taxis
//
//  Created by jerome tonnelier on 06/04/2016.
//  Copyright © 2016 jerome tonnelier. All rights reserved.
//

import UIKit

protocol Identifiable {
    static var identifier: String { get }
}

extension UITableViewCell: Identifiable {
    static var identifier: String { return String(describing: self) }
}

extension UICollectionViewCell : Identifiable  {
    static var identifier: String { return String(describing: self) }
}


enum ReloadAnimationType {
    case firstReload, leftToRight, rightToLeft
}

enum CellAnimation {
    case fromLeft
    case fromRight
    case fromBottom
    case fromTop
    case sncfStyle
    
    var duration: TimeInterval {
        switch self {
        case .sncfStyle: return 0.5
        default: return 0.5
        }
    }
    var delay: Double {
        switch self {
        case .sncfStyle: return 0.1
        default: return 0.05
        }
    }
    var scrollToTop: Bool {
        switch self {
//        case .sncfStyle: return false
        default: return false
        }
    }
}

extension UITableView {
    
    func animateTableFromRight() {
        self.animateTableFrom(.fromRight)
    }
    func animateTableFromTop() {
        self.animateTableFrom(.fromTop)
    }
    func animateTableFromLeft() {
        self.animateTableFrom(.fromLeft)
    }
    func animateTableFromBottom() {
        self.animateTableFrom(.fromBottom)
    }
    func reloadSncfStyle() {
        self.animateTableFrom(.sncfStyle)
    }
    
    
    func animateTableFrom(_ from: CellAnimation) {
        reloadData()
        
        guard dataSource?.tableView(self, numberOfRowsInSection: 0) ?? 0 > 0 else {
            return
        }
        
        if from.scrollToTop {
            scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
        
        visibleCells.forEach { (cell) in
            
            switch from {
            case .fromRight:
                cell.transform = CGAffineTransform(translationX: 100, y: 0)
                cell.alpha = 0
            case .fromLeft:
                cell.transform = CGAffineTransform(translationX: -cell.frame.width, y: 0)
                cell.alpha = 0
            case .fromTop:
                cell.transform = CGAffineTransform(translationX: 0, y: -self.frame.height)
                cell.alpha = 0
            case .fromBottom:
                cell.transform = CGAffineTransform(translationX: 0, y: self.frame.height)
                cell.alpha = 0
            case .sncfStyle:
                cell.contentView.layer.transform        = CATransform3DMakeRotation(-(CGFloat.pi / 2), 1, 0, 0)
                cell.contentView.layer.anchorPoint      = CGPoint(x: 0.5, y: 0.0)
                cell.contentView.layer.transform.m34    = 0.008

            }
        }
        
        for (index, cell) in visibleCells.enumerated() {
            UIView.animate(withDuration: from.duration, delay: from.delay * Double(index), usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8, options: .curveEaseInOut, animations: {
                switch from {
                case .sncfStyle:
                    cell.contentView.layer.transform = CATransform3DIdentity
                    
                default:
                    cell.transform = CGAffineTransform.identity
                    cell.alpha = 1
                }
            }, completion: nil)
        }
    }
}

extension UITableView {
    
    /**
     Automatically dequeues a cell with an identifier equal to the cell Class
     
     - returns:
     The according cell if dequeueReusableCell(withIdentifier: , for: ) succeed, nil otherwise
     
     - parameters:
        - indexPath: the indexPath of the cell we want to dequeue
     
     - important:
     The cell identifier must be set to the Class name in the storyboard, otherwise this method will not work
     */
    func automaticallyDequeueReusableCell<T: Identifiable>(forIndexPath indexPath: IndexPath) -> T? {
        let identifier = T.identifier
        return self.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? T
    }
    
    func didScrollToTop() -> Bool {
        let cells = visibleCells
        guard !cells.isEmpty else { return true }
        guard let path = indexPath(for: cells.first!) else { return true }
        return path.section == 0 && path.row == 0
    }
    
    /**
     Register a cell conforming to Identifiable protocol using its xib
     */
    func register(cell: Identifiable.Type) {
        let nib = UINib(nibName: cell.identifier, bundle: nil)
        self.register(nib, forCellReuseIdentifier: cell.identifier)
    }
    
    /**
     Register a cell conforming to Identifiable protocol without xib
     */
    func registerIdentifiable(cell: Identifiable.Type) {
        self.register(cell.self as? AnyClass, forCellReuseIdentifier: cell.identifier)
    }

    
    func commonInit() {
//        self.separatorColor = Palette.basic.lightBackgroundAndSeparator.uicolor
        rowHeight = UITableView.automaticDimension
//        estimatedRowHeight = UITableViewAutomaticDimension
        tableFooterView = UIView()
        backgroundColor = .white
        if #available(iOS 11.0, *) {
            contentInsetAdjustmentBehavior = .never
        }
    }
    
}

extension UICollectionView {
    func automaticallyDequeueReusableCell<T: Identifiable>(forIndexPath indexPath: IndexPath) -> T? {
        let identifier = T.identifier
        return self.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? T
    }
    
    func register(cell: Identifiable.Type) {
        let nib = UINib(nibName: cell.identifier, bundle: nil)
        self.register(nib, forCellWithReuseIdentifier: cell.identifier)
    }
}
