//
//  LoginViewController.swift
//  TripSplit
//
//  Created by Noah Woodward on 12/22/18.
//  Copyright © 2018 Noah Woodward. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        errorLabel.isHidden = true
        
        
        
    }
    
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        guard let email = emailTextField.text else {return}
        guard let password = passwordTextField.text else {return}
        
        UserService.login(email: email, password: password) { (user, err) in
            if let err = err {
                self.errorLabel.isHidden = false
                self.errorLabel.text = "There was an issue with the login"
            }
            guard let user = user else {fatalError("Attempted to register but not given back a valid user in closure")}
            User.setCurrent(user, writeToUserDefaults: true)
            self.performSegue(withIdentifier: "toHomeFromLogin", sender: nil)
        }
        
    }
    



}
