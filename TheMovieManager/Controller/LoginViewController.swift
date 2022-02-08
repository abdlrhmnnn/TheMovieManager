//
//  LoginViewController.swift
//  TheMovieManager
//
//  Created by Owen LaRosa on 8/13/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginViaWebsiteButton: UIButton!
    @IBOutlet weak var connectionIndicator: UIActivityIndicatorView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        emailTextField.text = ""
        passwordTextField.text = ""
    }
    
    @IBAction func loginTapped(_ sender: UIButton) {
        setLoggingIn(true)
        TMDBClient.getRequestToken(completion: handelRequestTokenResponse(success:error:))
    }
    
    @IBAction func loginViaWebsiteTapped() {
        performSegue(withIdentifier: "completeLogin", sender: nil)
    }
    func handelRequestTokenResponse (success: Bool , error: Error?){
        if success {
                TMDBClient.login(username: self.emailTextField.text ?? "", password: self.passwordTextField.text ?? "", completion: self.handelLoginResponse(success:error:))
        }else {
            print(error?.localizedDescription)
            showLoginFailure(message: error?.localizedDescription ?? "")
        }
    }
    func handelLoginResponse (success: Bool , error: Error?){
        
        if success {
            TMDBClient.createSessionId(completion: handelSessionId(success:error:))
        }else {
            print(error?.localizedDescription)
            showLoginFailure(message: error?.localizedDescription ?? "")
        }
    }
    func handelSessionId (success: Bool , error: Error?){
        
        if success {
            setLoggingIn(false)
            self.performSegue(withIdentifier: "completeLogin", sender: nil)
        }else{
            print(error?.localizedDescription)
            showLoginFailure(message: error?.localizedDescription ?? "")
        }
    }
    
    func setLoggingIn (_ loggingIn: Bool){
        if loggingIn {
            connectionIndicator.startAnimating()
        }else{
            connectionIndicator.stopAnimating()
        }
        emailTextField.isEnabled = !loggingIn
        passwordTextField.isEnabled = !loggingIn
        loginButton.isEnabled = !loggingIn
        loginViaWebsiteButton.isEnabled = !loggingIn
    }
    func showLoginFailure (message: String){
        let alertVC = UIAlertController(title: "Login Failed", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        show(alertVC, sender: nil)
        setLoggingIn(false)
    }
}
