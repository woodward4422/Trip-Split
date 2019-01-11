//
//  UserService.swift
//  TripSplit
//
//  Created by Noah Woodward on 12/15/18.
//  Copyright © 2018 Noah Woodward. All rights reserved.
//
import Foundation
import FirebaseAuth
import FirebaseDatabase

struct UserService {
    
    public static func getUser(uid: String, completion: @escaping (User?) -> Void) {
        let ref = Database.database().reference().child("users").child(uid)
        ref.observeSingleEvent(of: .value) { snapshot in
            print("snapshot \(snapshot.value as? [String : Any])")
            guard let val = snapshot.value as? [String : Any] else {
                
                return completion(nil)
            }
            let user = User(from: val)
            return completion(user)
        }
    }
    
    /**
     Registers a new user to Firebase Auth
    */
    static func register( // swiftlint:disable:this function_parameter_count
        name: String,
        email: String,
        password: String,
        completion: @escaping (_ user: User?, _ error: Error?) -> Void) {
        
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if let error = error {
                return completion(nil, error)
            }
            
            guard let firUser = result?.user else {
                fatalError("no user from result but no error was found")
            }
            
            UserService.create(
                uid: firUser.uid,
                name: name,
                email: email,
                position: nil,
                completion: { (user) in
                    completion(user, nil)
            })
        }
    }
    
    /**
     Logs in an existing user
     */
    static func login(email: String, password: String, completion: @escaping (_ user: User?, _ error: Error?) -> Void) {
        
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if let error = error {
                return completion(nil, error)
            }
            
            guard let firUser = result?.user else {
                fatalError("no user from result but no error was found or, validation failed with register button")
            }
            
            print("Firebase UID: \(firUser.uid)")

            UserService.getUser(uid: firUser.uid, completion: { (user) in
                
                completion(user, nil)
            })
        }
    }
    
    /**
     Sends a password reset email
     */
    static func resetPassword(for email: String, completion: @escaping (Bool) -> ()) {
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            guard error == nil else {
                assertionFailure(error!.localizedDescription)
                
                return completion(false)
            }
            return completion(true)
        }
    }
    
    /**
     Creates a new User object and passes it to the completion
     */
    private static func create(
        uid: String,
        name: String,
        email: String,
        position: String?,
        completion: @escaping (User?) -> Void) {
            let newUser = User(uid: uid,
                               name: name,
                               email: email,
                               position: position)
            
            let ref = Database.database().reference().child("users").child(uid)
            
            ref.setValue(newUser.dictValue, withCompletionBlock: { (error, _) in
                if error != nil {
                    return completion(nil)
                }
                
                return completion(newUser)
            })
    }
    
    static func retrieveAuthErrorMessage(for error: Error) -> String {
        guard let errorCode = AuthErrorCode(rawValue: (error._code)) else {
            return "Something went wront, please try again."
        }
        
        switch errorCode {
        case .weakPassword:
            return "Password should contain atleast 6 characters."
        case .emailAlreadyInUse:
            return "This email is already in use."
        case .missingEmail:
            return "Missing email."
        case .invalidEmail:
            return "This email is invalid."
        case .wrongPassword:
            return "Password Wrong."
        case .userNotFound:
            return "No matching account with this credentials."
        default:
            return "Something went wront, please try again."
        }
    }
    
    static func update(user: User, completion: @escaping (Bool) -> Void) {
        let refUser = Database.database().reference().child("users").child(user.uid)
        refUser.updateChildValues(user.dictValue) { (error, _) in
            guard error == nil else {
                assertionFailure(error!.localizedDescription)
                
                return completion(false)
            }
            completion(true)
        }
    }
    
    static func addTrip(to user: User, trip: Trip, completion: @escaping (User?) -> Void) {
        var newUser = user
        newUser.addTrip(trip)
        // update in database
        self.update(user: newUser) { bool in
            if bool {
                completion(newUser)
            } else {
                completion(nil)
            }
        }
    }
    
    public static func getAllTrips(from user: User, completion: @escaping ([Trip]) -> Void) {
        let ref = Database.database().reference().child("users").child(user.uid).child("tripIDs")
        ref.observeSingleEvent(of: .value) { snapshot in
            guard let val = snapshot.value as? [String : Any] else {
                return completion([])
            }
            getTripsFromIDs(val, completion: { trips in
                return completion(trips)
            })
        }
    }
    
    private static func getTripsFromIDs(_ idMap: [String : Any], completion: @escaping ([Trip]) -> Void) {
        var trips: [Trip] = []
        let ref = Database.database().reference().child("trips")
        ref.observeSingleEvent(of: .value) { snapshot in
            let val = snapshot.value as? NSDictionary
            print("idMap: \(idMap)")
            for id in idMap {
                let trip = val?[id.key] as! [String: Any]
                let _trip = Trip(from: trip)
                if let __trip = _trip {
                    trips.append(__trip)
                }
            }
            return completion(trips)
        }
    }
    
    public static func pay(user: User, expense: Expense, completion: @escaping (Expense?) -> Void) {
        var newExpense = expense
        newExpense.addUserWhoPaid(user)
        ExpenseService.update(expense: newExpense) { bool in
            if bool {
                completion(newExpense)
            } else {
                completion(nil)
            }
        }
    }
    
    public static func getAllExpenses(for user: User, in trip: Trip, completion: @escaping ([Expense]) -> Void) {
        var expenses: [Expense] = []
        let ref = Database.database().reference().child("trips").child(trip.uid).child("expenseIDs")
        ref.observeSingleEvent(of: .value) { snapshot in
            guard let val = snapshot.value as? [String : Any] else {
                return completion([])
            }
            
            // get expense objects from ids
            TripService.getExpensesFromIDs(val, completion: { allExpenses in
                for exp in allExpenses {
                    if exp.users.contains(user.uid), !exp.usersWhoPaid.contains(user.uid) {
                        expenses.append(exp)
                    }
                }
                return completion(expenses)
            })
        }
    }
}
