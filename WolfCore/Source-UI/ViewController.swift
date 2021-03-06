//
//  ViewController.swift
//  WolfCore
//
//  Created by Robert McNally on 6/8/16.
//  Copyright © 2016 Arciem. All rights reserved.
//


import UIKit

public let viewControllerLifecycleLogGroup = "ViewControllers"

public class ViewController: UIViewController {
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _setup()
    }

    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        _setup()
    }

    private func _setup() {
        logInfo("init \(self)", group: viewControllerLifecycleLogGroup)
        setup()
    }

    public func setup() {
    }

    deinit {
        logInfo("deinit \(self)", group: viewControllerLifecycleLogGroup)
    }

    public override func awakeFromNib() {
        super.awakeFromNib()
        logInfo("awakeFromNib \(self)", group: viewControllerLifecycleLogGroup)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
    }

    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        updateAppearance()
    }

    /// Override in subclasses
    public func updateAppearance() { }
}
