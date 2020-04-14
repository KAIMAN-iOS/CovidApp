//
//  AskEmailViewController.swift
//  CovidApp
//
//  Created by jerome on 29/03/2020.
//  Copyright © 2020 Jerome TONNELIER. All rights reserved.
//

import UIKit

class AskEmailViewController: UIViewController {

    weak var coordinatorDelegate: AppCoordinatorDelegate? = nil
    static func create() -> AskEmailViewController {
        return AskEmailViewController.loadFromStoryboard(identifier: "AskEmailViewController", storyboardName: "Main")
    }
    
    var observation: NSKeyValueObservation?
    @IBOutlet weak var continueButton: ActionButton!  {
        didSet {
            continueButton.actionButtonType = .primary
        }
    }

    @IBOutlet weak var textField: ErrorTextField!  {
        didSet {
            textField.type = .email
            
        }
    }
    @IBOutlet weak var instructions: UILabel!  {
        didSet {
            instructions.text = "ask email instructions".local()
        }
    }

    
    deinit {
        print("💀 DEINIT \(URL(fileURLWithPath: #file).lastPathComponent)")
        observation?.invalidate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        continueButton.isEnabled = false
        
        // observe the isValid from ttf
        observation = observe(\.textField.isValid,
            options: [.old, .new]
        ) { [weak self] _, change in
            guard let self = self else { return }
            self.continueButton.isEnabled = change.newValue ?? false
        }
    }
    
    @IBAction func `continue`(_ sender: Any) {
        continueButton.isLoading = true
        CovidApi
            .shared
            .retrieveToken()
            .done { [weak self] user in
                self?.coordinatorDelegate?.showUserProfileController()
        }
        .catch { [weak self] error in
            self?.continueButton.isLoading = false
            MessageManager.show(.sso(.cantLogin(message: error.localizedDescription)))
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
