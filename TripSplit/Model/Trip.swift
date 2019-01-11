//
//  Trip.swift
//  TripSplit
//
//  Created by Noah Woodward on 12/15/18.
//  Copyright © 2018 Noah Woodward. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct Trip: JSONElement, Codable {
    let uid: String
    let title: String
    let location: String
    let code: String
    var users: [String]
    var expenses: [String]
    
    // be sure to add the user who created this trip
    init(uid: String, title: String, location: String, code: String) {
        self.uid = uid
        self.location = location
        self.title = title
        self.code = code
        self.users = []
        self.expenses = []
    }
    
    init?(from snapshot: DataSnapshot) {
        guard let dict = snapshot.value as? [String: Any] else {
            return nil
        }
        
        self.init(from: dict)
    }
    
    init?(from dictionary: [String: Any]) {
        guard
            let uid = dictionary["uid"] as? String,
            let location = dictionary["location"] as? String,
            let title = dictionary["title"] as? String,
            let code = dictionary["code"] as? String
            else {
                return nil
        }
    
        self.uid = uid
        self.location = location
        self.title = title
        self.code = code
        self.users = []
        self.expenses = []
        
        if let users = dictionary["userIDs"] as? [String : Any] {
            self.users = dictToArray(users)
        }
        if let expenses = dictionary["expenseIDs"] as? [String : Any] {
             self.expenses = dictToArray(expenses)
        }
       
    }
    
    public var dictValue : [String: Any] {
        return [
            "uid": uid,
            "location": location,
            "title": title,
            "code": code,
            "userIDs": self.arrayToDict(users),
            "expenseIDs": self.arrayToDict(expenses)
        ]
    }
    
    public func userOwes(_ user: User, completion: @escaping (Double) -> Void) {
        var sum = 0.0
        UserService.getAllExpenses(for: user, in: self) { expenseObjs in
            for expense in expenseObjs {
                sum += ExpenseService.getCostPerUser(for: expense)
            }
            return completion(sum)
        }
    }
    
    /**
    Only for use in TripService
    */
    mutating func addUser(_ user: User) {
        self.users.append(user.uid)
    }
    
    /**
     Only for use in TripService
     */
    mutating func addExpense(_ expense: Expense) {
        self.expenses.append(expense.uid)
    }
}
