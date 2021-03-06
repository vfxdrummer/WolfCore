//
//  NavigationBarExtensions.swift
//  WolfCore
//
//  Created by Robert McNally on 6/8/16.
//  Copyright © 2016 Arciem. All rights reserved.
//

import UIKit

extension UINavigationBar {
    public func setAppearance(barTintColor barTintColor: UIColor?, tintColor: UIColor?, titleColor: UIColor?) {
        self.barTintColor = barTintColor
        self.tintColor = tintColor
        var titleTextAttributes = [String: AnyObject]()
        if let titleColor = titleColor {
            titleTextAttributes[NSForegroundColorAttributeName] = titleColor
        }
        self.titleTextAttributes = titleTextAttributes
    }
}
