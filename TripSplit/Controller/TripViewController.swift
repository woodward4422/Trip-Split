//
//  ExpenseViewController.swift
//  TripSplit
//
//  Created by Noah Woodward on 12/18/18.
//  Copyright © 2018 Noah Woodward. All rights reserved.
//

import UIKit

class TripViewController: UIViewController {
    var currentTrip: Trip! 
    var expenses = [Expense]()
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewWillAppear(_ animated: Bool) {
        TripService.getTrip(uid: currentTrip.uid) { trip in
            guard let _trip = trip else {
                fatalError("trip does not exist")
            }
            UserService.getAllExpenses(for: User.current, in: _trip) { (loadedExpenses) in
                self.expenses = loadedExpenses
                self.collectionView.reloadData()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = currentTrip.title
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addExpenseButtonPressed(_ sender: Any) {
        let addExpenseVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "addExpense") as? AddExpenseViewController
        addExpenseVC?.currentTrip = self.currentTrip
        navigationController?.pushViewController(addExpenseVC!, animated: true)
        
    }
    
    
    @IBAction func seeUserInTripPressed(_ sender: UIBarButtonItem) {
        let seeUsersVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "seeUsersVC") as? SeeUsersInTripTableViewController
        seeUsersVC?.currentTrip = self.currentTrip
        navigationController?.pushViewController(seeUsersVC!, animated: true)
    }
    
    

    
    
}

extension TripViewController: UICollectionViewDelegate, UICollectionViewDataSource{
   
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return expenses.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "expenseCell", for: indexPath) as! ExpenseCollectionViewCell
        cell.expenseNameLabel.text = expenses[indexPath.row].title
        let price = ExpenseService.getCostPerUser(for: expenses[indexPath.row])
        cell.expenseCostLabel.text  = "$" + "\(price)"
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let payExpenseVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "payExpenseVC") as? PayExpenseViewController
        payExpenseVC?.currentExpense = expenses[indexPath.row]
        self.navigationController?.pushViewController(payExpenseVC!, animated: true)
    }
}
