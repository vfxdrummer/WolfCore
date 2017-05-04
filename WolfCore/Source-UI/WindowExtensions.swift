//
//  WindowExtensions.swift
//  WolfCore
//
//  Created by Wolf McNally on 5/18/16.
//  Copyright © 2016 Arciem. All rights reserved.
//

import UIKit

extension UIWindow {
    public func replaceRootViewController(with newController: UIViewController, animated: Bool = true) -> SuccessPromise {
        func perform(promise: SuccessPromise) {
            let snapshotImageView = UIImageView(image: snapshot())
            self.addSubview(snapshotImageView)

            func onCompletion() {
                snapshotImageView.removeFromSuperview()
                promise.keep()
            }

            func animateTransition() {
                rootViewController = newController
                bringSubview(toFront: snapshotImageView)
                if animated {
                    dispatchAnimated {
                        snapshotImageView.alpha = 0
                    }.then { _ in
                        onCompletion()
                    }.run()
                } else {
                    onCompletion()
                }
            }

            if let presentedViewController = rootViewController?.presentedViewController {
                presentedViewController.dismiss(animated: false) {
                    animateTransition()
                }
            } else {
                animateTransition()
            }
        }

        return SuccessPromise(with: perform)
    }

    public func updateForOrientation() {
        let orientation = UIApplication.shared.statusBarOrientation
        transform = transformForOrientation(orientation)

        let screen = UIScreen.main
        let screenRect = screen.nativeBounds
        let scale = screen.nativeScale
        frame = CGRect(x: 0, y: 0, width: screenRect.width / scale, height: screenRect.height / scale)
    }
}

public func transformForOrientation(_ orientation: UIInterfaceOrientation) -> CGAffineTransform {
    switch orientation {
    case .landscapeLeft:
        return CGAffineTransform(rotationAngle: radians(for: -90))
    case .landscapeRight:
        return CGAffineTransform(rotationAngle: radians(for: 90))
    case .portraitUpsideDown:
        return CGAffineTransform(rotationAngle: radians(for: 180))
    default:
        return CGAffineTransform(rotationAngle: radians(for: 0))
    }
}

public func printWindows() {
    for window in UIApplication.shared.windows {
        print("\(window), windowLevel: \(window.windowLevel)")
    }
}
