//
//  KeyboardMovement.swift
//  WolfCore
//
//  Created by Robert McNally on 6/22/16.
//  Copyright © 2016 Arciem. All rights reserved.
//

import UIKit

public class KeyboardMovement: CustomStringConvertible {
    private let notification: NSNotification

    public init(notification: NSNotification) {
        self.notification = notification
    }

    public var frameBegin: CGRect {
        return (notification.userInfo![UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue()
    }

    public var frameEnd: CGRect {
        return (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue()
    }

    public func frameBegin(in view: UIView) -> CGRect {
        return view.convert(frameBegin, from: nil)
    }

    public func frameEnd(in view: UIView) -> CGRect {
        return view.convert(frameEnd, from: nil)
    }

    public var animationDuration: TimeInterval {
        return TimeInterval((notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).floatValue)
    }

    public var animationCurve: UIViewAnimationCurve {
        return UIViewAnimationCurve(rawValue: (notification.userInfo![UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).intValue)!
    }

    public var animationCurveOptions: UIViewAnimationOptions {
        switch animationCurve {
        case .easeInOut:
            return UIViewAnimationOptions(rawValue: 0)
        case .easeIn:
            return [.curveEaseIn]
        case .easeOut:
            return [.curveEaseOut]
        case .linear:
            return [.curveLinear]
        }
    }

    public var isLocal: Bool {
        return (notification.userInfo![UIKeyboardIsLocalUserInfoKey] as! NSNumber).boolValue
    }

    public var description: String {
        return notification.description
    }
}