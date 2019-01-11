//
//  UIWindow.swift
//  TripSplit
//
//  Created by Noah Woodward on 12/17/18.
//  Copyright © 2018 Noah Woodward. All rights reserved.
//

import Foundation
import UIKit.UIWindow

extension UIWindow {
    func setRootViewController(_ rootViewController: UIViewController) {
        self.rootViewController = rootViewController
        makeKeyAndVisible()
    }
}
