//
//  UIViewController+binkapp.swift
//  binkapp
//
//  Created by Pop Dorin on 13/11/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    var isModal: Bool {
        return self.presentingViewController?.presentedViewController == self
            || (self.navigationController != nil && self.navigationController?.presentingViewController?.presentedViewController == self.navigationController)
            || self.tabBarController?.presentingViewController is UITabBarController
    }
    
    func getVisibleViewController() -> UIViewController? {
        let rootVC = UIApplication.shared.keyWindow?.rootViewController

        if rootVC?.presentedViewController == nil {
            return rootVC
        }

        if let presented = rootVC?.presentedViewController {
            if presented.isKind(of: UINavigationController.self) {
                let navigationController = presented as? UINavigationController
                return navigationController?.viewControllers.last
            }

            if presented.isKind(of: UITabBarController.self) {
                let tabBarController = presented as? UITabBarController
                return tabBarController?.selectedViewController
            }

            return presented
        }
        return nil
    }
    
    static func topMostViewController() -> UIViewController? {
        let keyWindow = UIApplication.shared.keyWindow
        if var topController = keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            return topController
        }
        return nil
    }
}
