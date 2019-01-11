//
//  Expense.swift
//  TripSplit
//
//  Created by Noah Woodward on 12/15/18.
//  Copyright © 2018 Noah Woodward. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct Expense: JSONElement, Codable {
    let uid: String
    let title: String
    let cost: Double
    let tripUID: String
    var users: [String]
    var usersWhoPaid: [String]
    
    init(uid: String, title: String, cost: Double,tripUID: String, users: [String]) {
        self.uid = uid
        self.cost = cost
        self.users = users
        self.title = title
        self.tripUID = tripUID
        self.usersWhoPaid = []
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
            let cost = dictionary["cost"] as? Double,
            let title = dictionary["title"] as? String,
            let tripUID = dictionary["tripUID"] as? String
            else { return nil }
        
        self.uid = uid
        self.cost = cost
        self.title = title
        self.tripUID = tripUID
        self.users = []
        self.usersWhoPaid = []
        
        
        if let users = dictionary["userIDs"] as? [String : Any] {
            self.users = dictToArray(users)
        }
        if let usersWhoPaid = dictionary["userIDsWhoPaid"] as? [String : Any] {
            self.usersWhoPaid = dictToArray(usersWhoPaid)
        }
    }
    
    public var dictValue : [String: Any] {
        return [
            "uid": uid,
            "cost": cost,
            "title": title,
            "tripUID": tripUID,
            "userIDs": arrayToDict(users),
            "userIDsWhoPaid": arrayToDict(usersWhoPaid)
        ]
    }
    
    /**
     Only for use in ExpenseService
     */
    mutating func addUser(_ user: User) {
        self.users.append(user.uid)
    }
    
    /**
     Only for use in ExpenseService
     */
    mutating func addUserWhoPaid(_ user: User) {
        self.usersWhoPaid.append(user.uid)
    }
}
