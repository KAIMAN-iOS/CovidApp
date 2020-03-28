//
//  LoginViewController.swift
//  CovidApp
//
//  Created by jerome on 28/03/2020.
//  Copyright © 2020 Jerome TONNELIER. All rights reserved.
//

import UIKit
import FacebookLogin

class LoginViewController: UIViewController {

    static func create() -> LoginViewController {
        return LoginViewController.loadFromStoryboard(identifier: "LoginViewController", storyboardName: "Main")
    }
    
    @IBOutlet weak var facebookButton: Button!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func connect(_ sender: Any) {
        LoginManager().logIn(permissions: [Permission.email], viewController: self) { result in
            print("res \(result)")
            switch result {
            case .success(let granted, let declined, let token):
                DispatchQueue.main.async {
                    MessageManager.show(.basic(.custom(title: "Oups".local(), message: "testMessage", buttonTitle: nil, configuration: MessageDisplayConfiguration.notification)))
                }
                
                // todo
            case .failed(let error):
                MessageManager.show(.basic(.custom(title: "Oups".local(), message: error.localizedDescription, buttonTitle: nil, configuration: MessageDisplayConfiguration.alert)))
                
            default: ()
            }
        }
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
