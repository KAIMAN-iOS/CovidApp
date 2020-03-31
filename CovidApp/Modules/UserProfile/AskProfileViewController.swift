//
//  AskProfileViewController.swift
//  CovidApp
//
//  Created by jerome on 29/03/2020.
//  Copyright © 2020 Jerome TONNELIER. All rights reserved.
//

import UIKit

class AskProfileViewController: UIViewController {

    weak var coordinatorDelegate: AppCoordinatorDelegate? = nil
    static func create() -> AskProfileViewController {
        return AskProfileViewController.loadFromStoryboard(identifier: "AskProfileViewController", storyboardName: "Main")
    }
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var continueButton: ActionButton!  {
        didSet {
            continueButton.actionButtonType = .primary
        }
    }
    
    var nameObserver: NSKeyValueObservation?
    @IBOutlet weak var nameTextField: ErrorTextField!  {
        didSet {
            nameTextField.type = .lastName
            
        }
    }
    var firstnameObserver: NSKeyValueObservation?
    @IBOutlet weak var firstnameTextField: ErrorTextField!  {
        didSet {
            firstnameTextField.type = .firstName
            
        }
    }
    var dobObserver: NSKeyValueObservation?
    @IBOutlet weak var dobTextField: ErrorTextField!  {
        didSet {
            dobTextField.type = .birthDate
            
        }
    }
    
    
    deinit {
        print("💀 DEINIT \(URL(fileURLWithPath: #file).lastPathComponent)")
        nameObserver?.invalidate()
        firstnameObserver?.invalidate()
        dobObserver?.invalidate()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scrollView.flashScrollIndicators()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkValidity()
        
        // observe the isValid from ttf
        nameObserver = observe(\.nameTextField.isValid,
                               options: [.old, .new]
        ) { [weak self] _, change in
            self?.checkValidity()
        }
        firstnameObserver = observe(\.firstnameTextField.isValid,
                               options: [.old, .new]
        ) { [weak self] _, change in
            self?.checkValidity()
        }
        dobObserver = observe(\.dobTextField.isValid,
                               options: [.old, .new]
        ) { [weak self] _, change in
            self?.checkValidity()
        }
        // Do any additional setup after loading the view.
    }
    
    private func checkValidity() {
        continueButton.isEnabled = nameTextField.isValid && firstnameTextField.isValid && dobTextField.isValid
    }
    
    @IBAction func `continue`(_ sender: Any) {
        coordinatorDelegate?.showMainController()
    }
}
