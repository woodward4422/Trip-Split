//
//  TripService.swift
//  TripSplit
//
//  Created by Noah Woodward on 12/16/18.
//  Copyright © 2018 Noah Woodward. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct TripService {
    
    public static func getTrip(uid: String, completion: @escaping (Trip?) -> Void) {
        let ref = Database.database().reference().child("trips").child(uid)
        ref.observeSingleEvent(of: .value) { snapshot in
            guard let val = snapshot.value as? [String : Any] else {
                return completion(nil)
            }
            let trip = Trip(from: val)
            return completion(trip)
        }
    }
    
    /**
     Writes a new Trip to the database and passes the new Trip object to the completion
     */
    static func createTrip(
        for user: User,
        title: String,
        location: String,
        code: String,
        // String in completion acts as an error
        completion: @escaping (Trip?, String?) -> Void) {
        
        // check if code is not already in use
        codeIsInUse(code) { inUse in
            if (inUse) {
                return completion(nil, "Unique trip code is already in use")
            }
            
            //get ref for new trip
            let ref = Database.database().reference().child("trips").childByAutoId()
            
            //create trip and get dict value
            var trip = Trip(
                uid: ref.key!,
                title: title,
                location: location,
                code: code
            )
            trip.addUser(user)
            //send request
            update(trip: trip, completion: { bool in
                var newUser = user
                newUser.addTrip(trip)
                UserService.update(user: newUser, completion: { bool in
                    if bool {
                        completion(trip, nil)
                    } else {
                        completion(nil, nil)
                    }
                })
            })
        }
    }
    
    // returns nil if a trip with the given tripCode does not exist
    static func joinTrip(for user: User, tripCode: String, completion: @escaping (Trip?) -> Void) {
        getTripFromCode(tripCode) { tripOptional in
            guard var trip = tripOptional else {
                return completion(nil)
            }
            trip.addUser(user)
            update(trip: trip, completion: { bool in
                var newUser = user
                newUser.addTrip(trip)
                UserService.update(user: newUser, completion: { bool in
                    if bool {
                        completion(trip)
                    } else {
                        completion(nil)
                    }
                })
            })
        }
    }
    
    static func update(trip: Trip, completion: @escaping (Bool) -> Void) {
        let refTrip = Database.database().reference().child("trips").child(trip.uid)
        refTrip.updateChildValues(trip.dictValue) { (error, _) in
            guard error == nil else {
                assertionFailure(error!.localizedDescription)
                
                return completion(false)
            }
            completion(true)
        }
    }
    
    static func remove(trip: Trip, completion: @escaping (Bool) -> Void) {
        let refDonation = Database.database().reference().child("trips").child(trip.uid)
        refDonation.updateChildValues(trip.dictValue) { (error, _) in
            guard error == nil else {
                assertionFailure(error!.localizedDescription)
                
                return completion(false)
            }
            completion(true)
        }
    }
    
    static func addUser(to trip: Trip, user: User, completion: @escaping (Trip?) -> Void) {
        var newTrip = trip
        newTrip.addUser(user)
        // update in database
        self.update(trip: newTrip) { bool in
            if bool {
                completion(newTrip)
            } else {
                completion(nil)
            }
        }
    }
    
    static func addExpense(to trip: Trip, expense: Expense, completion: @escaping (Trip?) -> Void) {
        var newTrip = trip
        newTrip.addExpense(expense)
        // update in database
        self.update(trip: newTrip) { bool in
            if bool {
                completion(newTrip)
            } else {
                completion(nil)
            }
        }
    }
    
    static func getAllExpenses(from trip: Trip, completion: @escaping ([Expense]) -> Void) {
        let ref = Database.database().reference().child("trips").child(trip.uid).child("expenseIDs")
        ref.observeSingleEvent(of: .value) { snapshot in
            guard let val = snapshot.value as? [String : Any] else {
                return completion([])
            }
            getExpensesFromIDs(val, completion: { expenses in
                return completion(expenses)
            })
        }
    }
    
    // can refactor into one function
    private static func getUsersFromIDs(_ idMap: [String : Any], completion: @escaping ([User]) -> Void) {
        var users: [User] = []
        let ref = Database.database().reference().child("users")
        ref.observeSingleEvent(of: .value) { snapshot in
            let val = snapshot.value as? NSDictionary
            for id in idMap {
                let userDict = val?[id.key] as? [String: Any] ?? ["": ""]
                let user = User(from: userDict)
                if let _user = user {
                    users.append(_user)
                }
            }
            return completion(users)
        }
    }
    
    static func getExpensesFromIDs(_ idMap: [String : Any], completion: @escaping ([Expense]) -> Void) {
        var expenses: [Expense] = []
        let ref = Database.database().reference().child("expenses")
        ref.observeSingleEvent(of: .value) { snapshot in
            let val = snapshot.value as? NSDictionary
            for id in idMap {
                let expenseDict = val?[id.key] as? [String: Any] ?? ["": ""]
                let expense = Expense(from: expenseDict)
                if let _expense = expense {
                    expenses.append(_expense)
                }
            }
            return completion(expenses)
        }
    }
    
    public static func getTotalCost(from trip: Trip, completion: @escaping (Double) -> Void) {
        var totalCost: Double = 0.0
        getAllExpenses(from: trip) { expenses in
            for exp in expenses {
                totalCost += exp.cost
                return completion(totalCost)
            }
        }
    }
    
    private static func getTripFromCode(_ code: String, completion: @escaping (Trip?) -> Void) {
        let ref = Database.database().reference().child("trips").queryOrdered(byChild: "code").queryEqual(toValue: code)
        ref.observeSingleEvent(of: .value) { snapshot in
            guard let dict = snapshot.value as? [String: Any] else {
                return completion(nil)
            }
            let newDict = dict[(dict.first?.key)!] as? [String: Any]
            let trip = Trip(from: newDict!)
            return completion(trip)
        }
    }
    
    private static func codeIsInUse(_ code: String, completion: @escaping (Bool) -> Void) {
        getTripFromCode(code) { trip in
            guard let _ = trip else {
                return completion(false)
            }
            return completion(true)
        }
    }
    
    public static func getAllUsers(trip: Trip, completion: @escaping ([User]) -> Void) {
        getTrip(uid: trip.uid) { tripOpt in
            guard let trip = tripOpt else {
                fatalError("trip does not exist")
            }
            var idMap: [String : Any] = [:]
            trip.users.forEach({ str in
                idMap[str] = true
            })
            getUsersFromIDs(idMap, completion: { users in
                return completion(users)
            })
        }
    }
    
    public static func getExpenseIDs(trip: Trip, completion: @escaping ([String : Any]) -> Void) {
        let ref = Database.database().reference().child("trips").child(trip.uid).child("expenseIDs")
        ref.observeSingleEvent(of: .value) { snapshot in
            guard let val = snapshot.value as? [String : Any] else {
                return completion([:])
            }
            return completion(val)
        }
    }
    
    
    
}
