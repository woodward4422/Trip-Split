//
//  Dictionaryable.swift
//  TripSplit
//
//  Created by Noah Woodward on 12/15/18.
//  Copyright © 2018 Noah Woodward. All rights reserved.
//

import Foundation

protocol JSONElement {
    var dictValue: [String: Any] { get }
}

extension JSONElement {
    func dictToArray(_ dict: [String : Any]) -> [String] {
        var arr : [String] = []
        for keyval in dict {
            arr.append(keyval.key)
        }
        return arr
    }
    
    func arrayToDict(_ arr: [String]) -> [String : Any] {
        var dict : [String : Any] = [:]
        for str in arr {
            dict[str] = true
        }
        return dict
    }
}
