//
//  LoginViewController.swift
//  Feeder
//
//  Created by Aritro Paul on 6/20/21.
//

import UIKit
import AuthenticationServices

class LoginViewController: UIViewController {

    var user: User?
    var session: ASWebAuthenticationSession?
    var authed: Bool = false
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        API.shared.userDelegate = self
        if (UserDefaults.standard.string(forKey: "token") != nil) {
            API.token = UserDefaults.standard.string(forKey: "token") ?? ""
            authed = true
            loginButton.setTitle("Authenticated", for: .normal)
            loginButton.isUserInteractionEnabled = false
        }

        API.shared.getColors()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if authed {
            API.shared.getUser()
        }
        else {
            loginButton.setTitle("Login with GitHub", for: .normal)
            loginButton.isUserInteractionEnabled = true
        }
    }
    
    @IBAction func loginTapped(_ sender: Any) {
        authenticate()
    }
    
    func authenticate() {
        let base = "https://github.com/login/oauth"
        let endpoint = "/authorize?client_id=\(API.clientID)&scope=user,repo&redirect_uri=feeder://login/"
        guard let url = URL(string: base + endpoint) else { return }
        session  = ASWebAuthenticationSession(url: url, callbackURLScheme: API.callback) { url, error in
            let code = String(url?.absoluteString.split(separator: "=")[1] ?? "")
            API.shared.authenticate(code: code) { status in
                if status {
                    UserDefaults.standard.set(API.token, forKey: "token")
                    API.shared.getUser()
                }
                else {
                    print("Oops")
                }
            }
        }
        session?.presentationContextProvider = self
        session?.start()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destVC = segue.destination as? UINavigationController,
            let targetController = destVC.topViewController as? FeedViewController {
            targetController.user = self.user
        }
    }
    
}

extension LoginViewController: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return view.window!
    }
}

extension LoginViewController: UserDelegate {
    func DidGetUser(user: User) {
        print(user)
        self.user = user
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "feed", sender: Any?.self)
        }
    }
    
    func didFailWith(error: Error) {
        print(error)
    }
}
