//
//  UINavigationControllerExtension.swift
//  binkapp
//
//  Created by Nick Farrant on 08/04/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import UIKit

extension UINavigationController {
    func removeViewController(_ viewController: UIViewController) {
        if let index = viewControllers.firstIndex(where: { $0 == viewController }) {
            viewControllers.remove(at: index)
        }
    }
    
    func removeViewControllerBehind<T: UIViewController>(_ viewController: UIViewController, ifViewControllerBehindIsOfType type: T.Type? = nil) {
        if let currentIndex = viewControllers.firstIndex(of: viewController), currentIndex > 0 {
            let indexToRemove = currentIndex - 1
            guard let type = type else {
                viewControllers.remove(at: indexToRemove)
                return
            }
            
            if viewControllers[indexToRemove].isKind(of: type) {
                viewControllers.remove(at: indexToRemove)
            }
        }
    }
}
