//
//  CollectionViewCell.swift
//  WolfCore
//
//  Created by Robert McNally on 5/27/16.
//  Copyright © 2016 Arciem. All rights reserved.
//

import UIKit

open class CollectionViewCell: UICollectionViewCell, Skinnable {
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
        ~self
        setup()
    }

    open override func didMoveToSuperview() {
        super.didMoveToSuperview()
        guard superview != nil else { return }
        updateAppearanceContainer(skin: mySkin)
    }

    open func updateAppearance(skin: Skin?) {
        _updateAppearance(skin: skin)
    }

    open func setup() { }
}
