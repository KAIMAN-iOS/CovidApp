//
//  NoFriendsViewController.swift
//  CovidApp
//
//  Created by jerome on 30/03/2020.
//  Copyright © 2020 Jerome TONNELIER. All rights reserved.
//

import UIKit

class NoFriendsViewController: UIViewController {

    static func create() -> NoFriendsViewController {
        return NoFriendsViewController.loadFromStoryboard(identifier: "NoFriendsViewController", storyboardName: "Main")
    }
    weak var shareDelegate: ShareDelegate? = nil
    @IBOutlet weak var addFriendsButton: ActionButton!  {
        didSet {
            addFriendsButton.actionButtonType = .primary
            addFriendsButton.textColor = .white
            addFriendsButton.setTitle("add friends".local(), for: .normal)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func share(_ sender: Any) {
        shareDelegate?.share(from: self)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
