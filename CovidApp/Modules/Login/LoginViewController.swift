//
//  LoginViewController.swift
//  CovidApp
//
//  Created by jerome on 28/03/2020.
//  Copyright © 2020 Jerome TONNELIER. All rights reserved.
//

import UIKit
import FacebookLogin
import GoogleSignIn
import AuthenticationServices

class LoginViewController: UIViewController {

    enum CurrentSocialNetwork {
        case facebook, google, apple
    }
    @IBOutlet weak var stack: UIStackView!
    private var currentSocialNetwork: CurrentSocialNetwork = .facebook
    weak var coordinatorDelegate: AppCoordinatorDelegate? = nil
    static func create() -> LoginViewController {
        return LoginViewController.loadFromStoryboard(identifier: "LoginViewController", storyboardName: "Main")
    }
    
    @IBOutlet weak var facebookButton: ActionButton!  {
        didSet {
            facebookButton.actionButtonType = .connection(type: .facebook)
        }
    }
    
    @IBOutlet weak var googleButton: ActionButton!  {
        didSet {
            googleButton.actionButtonType = .connection(type: .google)
        }
    }
    @IBOutlet weak var instructions: UILabel!  {
        didSet {
            instructions.text = "login instructions".local()
        }
    }
    var appleButton: UIControl? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance()?.restorePreviousSignIn()
        if #available(iOS 13.0, *) {
            let appleButton = ASAuthorizationAppleIDButton()
            appleButton.addTarget(self, action: #selector(handleAuthorizationAppleIDButtonPress), for: .touchUpInside)
            stack.insertArrangedSubview(appleButton, at: 3)
            appleButton.snp.makeConstraints { make in
                make.height.equalTo(facebookButton.snp.height)
            }
            appleButton.roundedCorners = true
            appleButton.clipsToBounds = false
            appleButton.addShadow(roundCorners: false)
            self.appleButton = appleButton
        }
    }
    
    @available(iOS 13.0, *)
    @objc private func handleAuthorizationAppleIDButtonPress() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()

    }
    
    private func handleConnectResultFrom(sessionController session: SessionController) {
        // if there is no email, asks for the email
        guard session.email?.count ?? 0 > 0, session.email?.isValidEmail == true else {
            self.coordinatorDelegate?.showEmailController()
            return
        }
        self.register()
    }
    
    @IBAction func connectWithFacebook(_ sender: ActionButton) {
        currentSocialNetwork = .facebook
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
                        self.handleConnectResultFrom(sessionController: session)
                }
                
            case .failed(let error):
                self.facebookButton.isLoading = false
                MessageManager.show(.basic(.custom(title: "Oups".local(), message: error.localizedDescription, buttonTitle: nil, configuration: MessageDisplayConfiguration.alert)), in: self)
                
            default: ()
            }
        }
    }
    
    @IBAction func connectWithGoogle(_ sender: ActionButton) {
        currentSocialNetwork = .google
        GIDSignIn.sharedInstance()?.delegate = self
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    func register() {
        switch currentSocialNetwork {
        case .facebook: facebookButton.isLoading = true
        case .google: googleButton.isLoading = true
        case .apple: appleButton?.isEnabled = false
        }
        
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
}

//MARK:-
//MARK: Google Signin
extension LoginViewController: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        guard error == nil else {
            googleButton.isLoading = false
            MessageManager.show(.basic(.custom(title: "Oups".local(), message: error.localizedDescription, buttonTitle: nil, configuration: MessageDisplayConfiguration.alert)))
            return
        }
        guard let user = user else {
            googleButton.isLoading = false
            MessageManager.show(.request(.serverError))
            return
        }
        let session = SessionController()
        session.readFrom(googleUser: user)
        self.handleConnectResultFrom(sessionController: session)
    }
}

//MARK:-
//MARK: Apple
@available(iOS 13.0, *)
extension LoginViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            
            let session = SessionController()
            session.readFrom(appleIDCredential: appleIDCredential)
            self.handleConnectResultFrom(sessionController: session)
            
        case let passwordCredential as ASPasswordCredential:
            if passwordCredential.user.isValidEmail {
                var session = SessionController()
                session.email = passwordCredential.user
                self.handleConnectResultFrom(sessionController: session)
            } else {
                MessageManager.show(.sso(.emailNotGranted))
            }
            
        default: appleButton?.isEnabled = true
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        appleButton?.isEnabled = true
        MessageManager.show(.basic(.custom(title: "Oups".local(), message: error.localizedDescription, buttonTitle: nil, configuration: MessageDisplayConfiguration.alert)))
    }

}

@available(iOS 13.0, *)
extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        self.view.window!
    }
}
