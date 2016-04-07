//
//  ViewExtensions.swift
//  WolfCore
//
//  Created by Robert McNally on 7/3/15.
//  Copyright © 2015 Arciem LLC. All rights reserved.
//

#if os(iOS)
    import UIKit
    public typealias OSView = UIView
    public typealias OSEdgeInsets = UIEdgeInsets
    public let OSEdgeInsetsZero = UIEdgeInsetsZero
#elseif os(OSX)
    import Cocoa
    public typealias OSView = NSView
    public typealias OSEdgeInsets = NSEdgeInsets
    public let OSEdgeInsetsZero = NSEdgeInsetsZero
#endif

extension OSView {
    #if os(iOS)
    public func makeTransparent(debugColor debugColor: OSColor = OSColor.clearColor(), debug: Bool = false) {
        opaque = false
        backgroundColor = debug ? debugColor.colorWithAlphaComponent(0.25) : OSColor.Clear
    }
    #endif
    
    #if os(iOS)
    public func tranparentPointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        for subview in subviews {
            if !subview.hidden && subview.alpha > 0 && subview.userInteractionEnabled && subview.pointInside(convertPoint(point, toView: subview), withEvent: event) {
                return true
            }
        }
        return false
    }
    #endif
}

extension OSView {
    public func constrainToSuperview(active active: Bool = true, insets: OSEdgeInsets = OSEdgeInsetsZero) -> [NSLayoutConstraint] {
        assert(superview != nil, "View must have a superview.")
        let sv = superview!
        let constraints = [
            leadingAnchor == sv.leadingAnchor + insets.left,
            trailingAnchor == sv.trailingAnchor - insets.right,
            topAnchor == sv.topAnchor + insets.top,
            bottomAnchor == sv.bottomAnchor - insets.bottom
        ]
        if active {
            activateConstraints(constraints)
        }
        return constraints
    }
    
    public func constrain(toView view: OSView, active: Bool = true, insets: OSEdgeInsets = OSEdgeInsetsZero) -> [NSLayoutConstraint] {
        assert(superview != nil, "View must have a superview.")
        assert(view.superview != nil, "View must have a superview.")
        let constraints = [
            leadingAnchor == view.leadingAnchor + insets.left,
            trailingAnchor == view.trailingAnchor - insets.right,
            topAnchor == view.topAnchor + insets.top,
            bottomAnchor == view.bottomAnchor - insets.bottom
        ]
        if active {
            activateConstraints(constraints)
        }
        return constraints
    }
    
    public func constrainCenter(toCenterOfView view: OSView, active: Bool = true) -> [NSLayoutConstraint] {
        let constraints = [
            centerXAnchor == view.centerXAnchor,
            centerYAnchor == view.centerYAnchor
        ]
        if active {
            activateConstraints(constraints)
        }
        return constraints
    }
    
    public func constrainCenterToCenterOfSuperview(active active: Bool = true) -> [NSLayoutConstraint] {
        assert(superview != nil, "View must have a superview.")
        let sv = superview!
        let constraints = [
            centerXAnchor == sv.centerXAnchor,
            centerYAnchor == sv.centerYAnchor
        ]
        if active {
            activateConstraints(constraints)
        }
        return constraints
    }
    
    public func constrain(toSize size: CGSize, active: Bool = true) -> [NSLayoutConstraint] {
        let constraints = [
            widthAnchor == size.width,
            heightAnchor == size.height
        ]
        if active {
            activateConstraints(constraints)
        }
        return constraints
    }
}