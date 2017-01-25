//
//  View.swift
//  WolfCore
//
//  Created by Robert McNally on 7/6/15.
//  Copyright © 2015 Arciem LLC. All rights reserved.
//

#if os(iOS) || os(tvOS)
    import UIKit
#elseif os(macOS)
    import Cocoa
#endif

open class View: OSView, Skinnable {
    private var _mySkin: Skin?
    public var mySkin: Skin? {
        get { return _mySkin ?? inheritedSkin }
        set { _mySkin = newValue; updateAppearanceContainer(skin: _mySkin) }
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
        translatesAutoresizingMaskIntoConstraints = false
        setup()
    }

    open func setup() { }

    open func updateAppearance(skin: Skin?) {
        _updateAppearance(skin: skin)
    }

    #if os(iOS) || os(tvOS)

    var baseSize: CGSize!
    public var managesSublabelScaling = false

    /// Can be set from Interface Builder
    public var transparentToTouches: Bool = false

    /// Can be set from Interface Builder
    public var transparentBackground: Bool = false {
        didSet {
            if transparentBackground {
                makeTransparent()
            }
        }
    }

    /// Can be set from Interface Builder, or in the subclass's Setup() function.
    public var contentNibName: String? = nil

    private var endEditingAction: GestureRecognizerAction!

    /// Can be set from Interface Builder
    public var endsEditingWhenTapped: Bool = false {
        didSet {
            if endsEditingWhenTapped {
                endEditingAction = addAction(forGestureRecognizer: UITapGestureRecognizer()) { [unowned self] _ in
                    self.window?.endEditing(false)
                }
            } else {
                endEditingAction = nil
            }
        }
    }

    open override func awakeFromNib() {
        super.awakeFromNib()
        loadContentFromNib()
        setupSublabelScaling()
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        syncSublabelScaling()
    }
    #endif
}

#if os(macOS)
    extension View {
        open override var isFlipped: Bool {
            return true
        }
    }
#endif

#if os(iOS) || os(tvOS)
    extension View {

        func setupSublabelScaling() {
            guard managesSublabelScaling else { return }

            baseSize = bounds.size
            for label in descendantViews() as [Label] {
                label.resetBaseFont()
            }
            setNeedsLayout()
        }

        func syncSublabelScaling() {
            guard managesSublabelScaling else { return }

            let factor = bounds.height / baseSize.height
            for label in descendantViews() as [Label] {
                label.syncFontSize(toFactor: factor)
            }
        }
    }
#endif

extension View {

    #if os(iOS) || os(tvOS)
    override open func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if transparentToTouches {
            return isTransparentToTouch(at: point, with: event)
        } else {
            return super.point(inside: point, with: event)
        }
    }

    func loadContentFromNib() {
        if let contentNibName = contentNibName {
            let view = ~loadView(fromNibNamed: contentNibName, owner: self)
            transferContent(from: view)
        }
    }

    private func transferContent(from view: UIView) {
        // These are attributes that can be set from Interface Builder
        contentMode = view.contentMode
        tag = view.tag
        isUserInteractionEnabled = view.isUserInteractionEnabled
        isMultipleTouchEnabled = view.isMultipleTouchEnabled
        alpha = view.alpha
        backgroundColor = view.backgroundColor
        tintColor = view.tintColor
        isOpaque = view.isOpaque
        isHidden = view.isHidden
        clearsContextBeforeDrawing = view.clearsContextBeforeDrawing
        clipsToBounds = view.clipsToBounds
        autoresizesSubviews = view.autoresizesSubviews

        // Copy these arrays because the act of moving the subviews will remove constraints
        let constraints = view.constraints
        let subviews = view.subviews

        for subview in subviews {
            addSubview(subview)
        }

        for constraint in constraints {
            var firstItem = constraint.firstItem
            let firstAttribute = constraint.firstAttribute
            let relation = constraint.relation
            var secondItem = constraint.secondItem
            let secondAttribute = constraint.secondAttribute
            let multiplier = constraint.multiplier
            let constant = constraint.constant
            let priority = constraint.priority
            let identifier = constraint.identifier

            if firstItem === view {
                firstItem = self
            }
            if secondItem === view {
                secondItem = self
            }

            // swiftlint:disable:next custom_rules
            let newConstraint = NSLayoutConstraint(item: firstItem, attribute: firstAttribute, relatedBy: relation, toItem: secondItem, attribute: secondAttribute, multiplier: multiplier, constant: constant)
            newConstraint.priority = priority
            newConstraint.identifier = identifier
            addConstraint(newConstraint)
        }
    }
    #endif
}

extension View {
    public func osDidSetNeedsDisplay() {
    }

    #if os(iOS) || os(tvOS)
    override open func setNeedsDisplay() {
        super.setNeedsDisplay()
        osDidSetNeedsDisplay()
    }

    public func osSetNeedsDisplay() {
        setNeedsDisplay()
    }
    #endif

    #if os(macOS)
    override open var needsDisplay: Bool {
    didSet {
    osDidSetNeedsDisplay()
    }
    }

    public func osSetNeedsDisplay() {
    needsDisplay = true
    }

    open override func setNeedsDisplay(_ rect: CGRect) {
    super.setNeedsDisplay(rect)
    osDidSetNeedsDisplay()
    }
    #endif
}

extension OSView {
    public func _updateAppearance(skin: Skin?) {
    }
}
