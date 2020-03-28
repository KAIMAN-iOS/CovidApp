//
//  MainViewController.swift
//  CovidApp
//
//  Created by jerome on 26/03/2020.
//  Copyright © 2020 Jerome TONNELIER. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    static func create() -> MainViewController {
        return MainViewController.loadFromStoryboard(identifier: "MainViewController", storyboardName: "Main")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        (UIApplication.shared.delegate as? AppDelegate)?.appCoordinator.start()
        // Do any additional setup after loading the view.
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
