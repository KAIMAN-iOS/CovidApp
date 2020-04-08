//
//  UIViewControllerExr.swift
//  FindABox
//
//  Created by jerome on 16/09/2019.
//  Copyright © 2019 Jerome TONNELIER. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func addFeedback() {

    }
    
    func addImpact() {
        
    }
    
    static func loadFromStoryboard<T: UIViewController>(identifier: String? = nil, storyboardName: String? = nil) -> T {
        let classIdentifier = identifier ?? String(describing: T.self)
        let storyboard = UIStoryboard(name: storyboardName ?? classIdentifier, bundle: Bundle.main)
        return storyboard.instantiateViewController(withIdentifier: classIdentifier) as! T
    }
    
    static func loadFromNib<T: UIViewController>(nibName: String? = nil) -> T {
        let classIdentifier = nibName ?? String(describing: T.self)
        return T(nibName: classIdentifier, bundle: nil)
    }
    
    
    func showShareViewController(with items: [Any],
                                 excludedActivityTypes: [UIActivity.ActivityType] = [.addToReadingList, .assignToContact, .copyToPasteboard, .openInIBooks, .saveToCameraRoll]) {
        let shareController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        shareController.excludedActivityTypes = excludedActivityTypes
        
        present(shareController, animated: true, completion: {
//            UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor(displayP3Red: 0, green: 122/255, blue: 1, alpha: 1)], for: .normal)
//            UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        })
        
        shareController.completionWithItemsHandler = { (activity, success, items, error) in
//            UIBarButtonItem.appearance().setTitleTextAttributes(textAtt, for: UIControl.State.normal)
//            UINavigationBar.appearance().titleTextAttributes = titleAtt
        }
    }
}
