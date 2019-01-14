//
//  RegisterViewController.swift
//  TripSplit
//
//  Created by Noah Woodward on 12/16/18.
//  Copyright © 2018 Noah Woodward. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {

    @IBOutlet weak var emailTextfField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var nameTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func registerButtonPressed(_ sender: UIButton) {
        guard let name = nameTextField.text else {fatalError("User did not enter a valid name")}
        guard let email = emailTextfField.text else {fatalError("User did not enter a valid email")}
        guard let password = passwordTextField.text else {fatalError("User did not enter a valid password")}
        UserService.register(name: name, email: email, password: password) { (user, err) in
            print("error: \(err?.localizedDescription)")
            guard let user = user else {fatalError("Attempted to register but not given back a valid user in closure")}
            User.setCurrent(user, writeToUserDefaults: true)
            self.performSegue(withIdentifier: "toHomeVC", sender: nil)
        }
        
    }
    
    @IBAction func unwindToHome(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    

  

}
