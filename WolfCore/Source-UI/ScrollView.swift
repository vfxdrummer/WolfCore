//
//  ScrollView.swift
//  WolfCore
//
//  Created by Robert McNally on 12/7/15.
//  Copyright © 2015 Arciem. All rights reserved.
//

import UIKit

open class ScrollView: UIScrollView, Skinnable {
    public var skinChangedAction: SkinChangedAction!

    /// Can be set from Interface Builder
    public var transparentToTouches: Bool = false

    /// Can be set from Interface Builder
    public var transparentBackground = false {
        didSet {
            if transparentBackground {
                makeTransparent()
            }
        }
    }

    public convenience init() {
        self.init(frame: .zero)
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        _setup()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _setup()
    }

    private func _setup() {
        ~self
        setup()
        setupSkinnable()
    }

    open override func didMoveToSuperview() {
        super.didMoveToSuperview()
        guard superview != nil else { return }
        updateAppearance()
    }

    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if transparentToTouches {
            return isTransparentToTouch(at: point, with: event)
        } else {
            return super.point(inside: point, with: event)
        }
    }

    open func setup() { }

    open func updateAppearance() { }
}
