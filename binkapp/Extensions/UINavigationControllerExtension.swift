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
                if visible {
                    self.navigationBar.standardAppearance.backgroundColor = .init(white: 1.0, alpha: 0.6)
                    self.navigationBar.standardAppearance.backgroundEffect = UIBlurEffect(style: .light)
                } else {
                    self.navigationBar.standardAppearance.backgroundEffect = nil
                    self.navigationBar.standardAppearance.backgroundColor = .clear
                }
                self.navigationBar.layoutIfNeeded()
            }
        } else {
            self.navigationBar.subviews.forEach({ navBarView in
                guard let blurView = navBarView as? UIVisualEffectView else { return }
                UIView.animate(withDuration: animationDuration) {
                    if visible {
                        blurView.effect = UIBlurEffect(style: .light)
                        blurView.backgroundColor = .init(white: 1.0, alpha: 0.6)
                    } else {
                        blurView.effect = nil
                        blurView.backgroundColor = .clear
                    }
                }
            })
        }
    }
}
