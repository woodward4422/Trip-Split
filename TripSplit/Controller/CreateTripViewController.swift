//
//  CreateTripViewController.swift
//  TripSplit
//
//  Created by Noah Woodward on 12/15/18.
//  Copyright © 2018 Noah Woodward. All rights reserved.
//

import UIKit

class CreateTripViewController: UIViewController {
    
    @IBOutlet weak var tripNameTitleField: UITextField!
    
    @IBOutlet weak var locationNameField: UITextField!
    
    
    @IBOutlet weak var codeTextField: UITextField!
    
    @IBOutlet weak var joinCodeEntryField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    //TODO: Add the trip firebase service to create a trip
    @IBAction func createTripButtonPressed(_ sender: UIButton) {
        guard let tripName = tripNameTitleField.text else {return}
        guard let locationName = locationNameField.text else {return}
        guard let code = codeTextField.text else {return}
        
        
        UserService.getUser(uid: User.current.uid) { user in
            guard let currUser = user else {
                fatalError("curr User does not exist")
            }
            TripService.createTrip(for: currUser, title: tripName, location: locationName, code: code) { (trip, error) in
                guard let trip = trip else {fatalError("Issue with creating the trip")}
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    
    @IBAction func joinTripButtonPressed(_ sender: UIButton) {
        guard let joinCode = joinCodeEntryField.text else {return}
        
        UserService.getUser(uid: User.current.uid) { user in
            guard let currUser = user else {
                fatalError("curr user does not exist")
            }
            TripService.joinTrip(for: currUser , tripCode: joinCode) { trip in
                guard let trip = trip else {fatalError("Nil Trip passed back when trying to join")}
                self.navigationController?.popViewController(animated: true)
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
