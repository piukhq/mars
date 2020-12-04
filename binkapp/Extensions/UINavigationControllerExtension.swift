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
    
    func setNavigationBarVisibility(_ visible: Bool, animated: Bool = true) {
        let animationDuration = animated ? 0.2 : 0.0
        
        if #available(iOS 13.0, *) {
            UIView.animate(withDuration: animationDuration) {
                self.navigationBar.standardAppearance.backgroundEffect = visible ? UIBlurEffect(style: .light) : nil
                self.navigationBar.standardAppearance.backgroundColor = visible ? UIColor(white: 1.0, alpha: 0.6) : .clear
                self.navigationBar.layoutIfNeeded()
            }
        } else {
            navigationBar.subviews.forEach({ navBarView in
                guard let blurView = navBarView as? UIVisualEffectView else { return }
                UIView.animate(withDuration: animationDuration) {
                    blurView.effect = visible ? UIBlurEffect(style: .light) : nil
                    blurView.backgroundColor = visible ? UIColor(white: 1.0, alpha: 0.6) : .clear
                }
            })
        }
    }
}
