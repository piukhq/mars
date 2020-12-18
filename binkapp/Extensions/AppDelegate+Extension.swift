//
//  AppDelegate+Extension.swift
//  binkapp
//
//  Created by Paul Tiriteu on 10/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

extension UIApplication {
    func topViewControllerWithRootViewController(rootViewController: UIViewController?) -> UIViewController? {
        guard let rootViewController = rootViewController else { return nil }
        if rootViewController is UITabBarController {
            return topViewControllerWithRootViewController(rootViewController: (rootViewController as? UITabBarController)?.selectedViewController)
        } else if rootViewController is UINavigationController {
            return topViewControllerWithRootViewController(rootViewController: (rootViewController as? UINavigationController)?.visibleViewController)
        } else if rootViewController.presentedViewController != nil {
            return topViewControllerWithRootViewController(rootViewController: rootViewController.presentedViewController)
        }
        return rootViewController
    }
}
