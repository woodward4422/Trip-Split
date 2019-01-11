//
//  AddExpenseViewController.swift
//  TripSplit
//
//  Created by Noah Woodward on 12/21/18.
//  Copyright © 2018 Noah Woodward. All rights reserved.
//

import UIKit

class AddExpenseViewController: UIViewController {
    @IBOutlet weak var expenseNameTextField: UITextField!
    
    
    @IBOutlet weak var expensePriceTextField: UITextField!
    
    var currentTrip: Trip!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(currentTrip)
        self.title = "Add Expense"
    }
    
    @IBAction func createExpenseButtonPressed(_ sender: UIButton) {
        guard let expenseName = expenseNameTextField.text ,
            let expensePrice = expensePriceTextField.text else {return}
        TripService.getTrip(uid: currentTrip.uid) { trip in
            guard let _trip = trip else {
                fatalError("no current trip")
            }

            print("_trip \(_trip)")
            ExpenseService.createExpense(in: _trip, title: expenseName, cost: Double(expensePrice)!, userIDs: _trip.users) { (expense) in
                guard let expense = expense else {return}
                self.navigationController?.popViewController(animated: true)
            }
        }
        
    }
    
}
