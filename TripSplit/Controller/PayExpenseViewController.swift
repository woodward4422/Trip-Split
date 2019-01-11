//
//  PayExpenseViewController.swift
//  TripSplit
//
//  Created by Noah Woodward on 12/27/18.
//  Copyright © 2018 Noah Woodward. All rights reserved.
//

import UIKit

class PayExpenseViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var currentExpense: Expense!
    var users: [User] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        ExpenseService.getUsers(from: currentExpense) { users in
            self.users = users
            print("users \(users)")
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.title = currentExpense.title
    }
    
    @IBAction func payExpenseButtonPressed(_ sender: UIButton) {
        UserService.pay(user: User.current, expense: currentExpense) { (expense) in
            guard let expense = expense else{fatalError("Bad Expense Being Payed")}
            self.navigationController?.popViewController(animated: true)
            
            
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifierUsers", for: indexPath)
        
        // Configure the cell...
        cell.textLabel?.text = users[indexPath.row].name
        
        return cell
    }
    
}
