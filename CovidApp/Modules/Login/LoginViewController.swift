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

    weak var coordinatorDelegate: AppCoordinatorDelegate? = nil
    static func create() -> LoginViewController {
        return LoginViewController.loadFromStoryboard(identifier: "LoginViewController", storyboardName: "Main")
    }
    
    @IBOutlet weak var facebookButton: ActionButton!  {
        didSet {
            facebookButton.actionButtonType = .connection(type: .facebook)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func connect(_ sender: Any) {
        LoginManager().logIn(permissions: [.email, .publicProfile, .userBirthday], viewController: self) { result in
            print("res \(result)")
            switch result {
            case .success:
                GraphRequest
                    .init(graphPath: "me", parameters: ["fields" : "id, last_name, first_name, email, birthday"])
                    .start { [weak self] (connection, result, error) in
                        guard let self = self else { return }
                        // if there are no data, asks for the email
                        guard let data = result as? [String : String] else {
                            self.coordinatorDelegate?.showEmailController()
                            return
                        }
                        let session = SessionController()
                        session.readFromFacebook(data)
                        
                        // if there is no email, asks for the email
                        guard session.email?.count ?? 0 > 0, session.email?.isValidEmail == true else {
                            self.coordinatorDelegate?.showEmailController()
                            return
                        }
                        self.register()
                }
                
            case .failed(let error):
                MessageManager.show(.basic(.custom(title: "Oups".local(), message: error.localizedDescription, buttonTitle: nil, configuration: MessageDisplayConfiguration.alert)), in: self)
                
            default: ()
            }
        }
    }
    
    func register() {
        facebookButton.isLoading = true
        CovidApi
            .shared
            .retrieveToken()
            .done { [weak self] user in
                var session = SessionController()
                session.token = user.token
                session.refreshToken = user.refreshToken
                self?.coordinatorDelegate?.showUserProfileController()
        }
        .catch { [weak self] error in
            guard let self = self else { return }
            self.facebookButton.isLoading = false
            SessionController().clear()
            MessageManager.show(.sso(.cantLogin(message: error.localizedDescription)), in: self)
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
