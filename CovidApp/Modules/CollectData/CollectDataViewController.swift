//
//  CollectDataViewController.swift
//  CovidApp
//
//  Created by jerome on 30/03/2020.
//  Copyright © 2020 Jerome TONNELIER. All rights reserved.
//

import UIKit

class CollectDataViewController: UIViewController {

    @IBOutlet weak var swipeCardStack: SwipeCardStack!
    @IBOutlet weak var noButton: ActionButton!
    @IBOutlet weak var yesButton: ActionButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var rewindButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func chooseNo(_ sender: Any) {
    }
    
    @IBAction func chooseYes(_ sender: Any) {
    }
    
    @IBAction func rewind(_ sender: Any) {
    }
    
    @IBAction func close(_ sender: Any) {
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
