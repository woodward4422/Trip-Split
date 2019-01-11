//
//  ExpenseService.swift
//  TripSplit
//
//  Created by Noah Woodward on 12/16/18.
//  Copyright © 2018 Noah Woodward. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct ExpenseService {
    
    public static func getExpense(uid: String, completion: @escaping (Expense?) -> Void) {
        let ref = Database.database().reference().child("expenses").child(uid)
        ref.observeSingleEvent(of: .value) { snapshot in
            guard let val = snapshot.value as? [String : Any] else {
                
                return completion(nil)
            }
            let expense = Expense(from: val)
            return completion(expense)
        }
    }
    
    /**
     Writes a new Expense to the database and passes the new Expense object to the completion
     */
    static func createExpense(
        in trip: Trip,
        title: String,
        cost: Double,
        userIDs: [String],
        completion: @escaping (Expense?) -> Void) {
        
        //get ref for new expense
        let ref = Database.database().reference().child("expenses").childByAutoId()
        //create expense and get dict value
        let expense = Expense(
            uid: ref.key!,
            title: title,
            cost: cost,
            tripUID: trip.uid,
            users: userIDs
        )
        
        let expenseDict = expense.dictValue
        //send request
        ref.updateChildValues(expenseDict) { error, _ in
            if let error = error {
                assertionFailure(error.localizedDescription)
                
                return completion(nil)
            }
            var newTrip = trip
            newTrip.addExpense(expense)
            TripService.update(trip: newTrip, completion: { bool in
                if bool {
                    completion(expense)
                } else {
                    completion(nil)
                }
            })
        }
    }
    
    static func update(expense: Expense, completion: @escaping (Bool) -> Void) {
        let refExpense = Database.database().reference().child("expenses").child(expense.uid)
        refExpense.updateChildValues(expense.dictValue) { (error, _) in
            guard error == nil else {
                assertionFailure(error!.localizedDescription)
                return completion(false)
            }
            return completion(true)
        }
    }
    
    static func remove(expense: Expense, completion: @escaping (Bool) -> Void) {
        let refExpense = Database.database().reference().child("expenses").child(expense.uid)
        refExpense.removeValue { (error, _) in
            guard error == nil else {
                assertionFailure(error!.localizedDescription)
                return completion(false)
            }
        }
        let refTrip = Database.database().reference().child("trips").child(expense.tripUID)
        refTrip.observeSingleEvent(of: .value) { snapshot in
            var ids: [String] = snapshot.value(forKey: "expenseIDs") as! [String]
            ids.remove(at: ids.firstIndex(of: expense.uid)!)
            refTrip.updateChildValues(["expenseIDs": ids], withCompletionBlock: { (error, _) in
                guard error == nil else {
                    assertionFailure(error!.localizedDescription)
                    fatalError("failed to update expense IDs")
                }
                return completion(true)
            })
        }
    }
    
    static func addUser(to expense: Expense, user: User, completion: @escaping (Expense?) -> Void) {
        var newExpense = expense
        newExpense.addUser(user)
        // update in database
        self.update(expense: newExpense) { bool in
            if bool {
                completion(newExpense)
            } else {
                completion(nil)
            }
        }
    }
    
    static func getUsers(from expense: Expense, completion: @escaping ([User]) -> Void) {
        self.getUsersGivenPath(from: expense, path: "userIDs", completion: completion)
    }
    
    static func getUsersWhoPaid(from expense: Expense, completion: @escaping ([User]) -> Void) {
        self.getUsersGivenPath(from: expense, path: "userIDsWhoPaid", completion: completion)
    }
    
    // factoring out the code of the above two functions
    private static func getUsersGivenPath(from expense: Expense, path: String, completion: @escaping ([User]) -> Void) {
        let ref = Database.database().reference().child("expenses").child(expense.uid).child(path)
        ref.observeSingleEvent(of: .value) { snapshot in
            let val = snapshot.value as? [String : Any]
            getUsersFromIDs(val!, completion: { users in
                completion(users)
            })
        }
    }
    
    // can refactor into one function
    static func getUsersFromIDs(_ idMap: [String : Any], completion: @escaping ([User]) -> Void) {
        var users: [User] = []
        let ref = Database.database().reference().child("users")
        ref.observeSingleEvent(of: .value) { snapshot in
            let val = snapshot.value as? NSDictionary
            for id in idMap {
                let user = val?[id.key] as? [String: Any] ?? ["": ""]
                let _user = User(from: user)
                if let __user = _user {
                    users.append(__user)
                }
            }
            return completion(users)
        }
    }
    
    static func addUserWhoPaid(to expense: Expense, user: User, completion: @escaping (Expense?) -> Void) {
        var newExpense = expense
        newExpense.addUserWhoPaid(user)
        // update in database
        self.update(expense: newExpense) { bool in
            if bool {
                completion(newExpense)
            } else {
                completion(nil)
            }
        }
    }
    
    static func getCostPerUser(for expense: Expense) -> Double {
        return expense.cost / Double(expense.users.count)
    }
}
