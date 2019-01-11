//
//  User.swift
//  TripSplit
//
//  Created by Noah Woodward on 12/15/18.
//  Copyright © 2018 Noah Woodward. All rights reserved.
//
import Foundation
import FirebaseDatabase

struct User: JSONElement, Codable {
    let uid: String
    let name: String
    let email: String
    let position: String?
    var trips: [String] // will save as an array of tripIDs in Firebase
    
    init(uid: String, name: String, email: String, position: String?) {
        self.uid = uid
        self.name = name;
        self.email = email;
        self.position = position
        self.trips = []
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
            let name = dictionary["name"] as? String,
            let email = dictionary["email"] as? String,
            let position = dictionary["position"] as? String?
            else {
                return nil
        }
        
        self.uid = uid
        self.name = name
        self.email = email
        self.position = position
        self.trips = []
        if let trips = dictionary["tripIDs"] as? [String : Any] {
            self.trips = dictToArray(trips)
        }
    }
    
    public var dictValue : [String: Any] {
        return [
            "uid": uid,
            "name": name,
            "email": email,
            "position": position ?? "",
            "tripIDs": self.arrayToDict(trips)
        ]
    }
    
    public static var current: User {
        guard let currentUser = _current else {
            fatalError("current user doesn't exist")
        }
        return currentUser
    }
    
    private static var _current: User?
    
    public static func setCurrent(_ user: User, writeToUserDefaults: Bool = false) {
        if writeToUserDefaults {
            if let data = try? JSONEncoder().encode(user) {
                UserDefaults.standard.set(data, forKey: "currentUser")
            }
        }
        
        _current = user
    }
    
    /**
     Only for use in UserService
     */
    mutating func addTrip(_ trip: Trip) {
        self.trips.append(trip.uid)
    }
}
