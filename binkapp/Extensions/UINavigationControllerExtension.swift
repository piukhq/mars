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
    
    func setNavigationBarInvisible(_ invisible: Bool) {
        if #available(iOS 13.0, *) {
            UIView.animate(withDuration: 0.2) {
                if invisible {
                    self.navigationBar.standardAppearance.backgroundEffect = nil
                    self.navigationBar.standardAppearance.backgroundColor = .clear
                } else {
                    self.navigationBar.standardAppearance.backgroundColor = .init(white: 1.0, alpha: 0.6)
                    self.navigationBar.standardAppearance.backgroundEffect = UIBlurEffect(style: .light)
                }
                self.navigationBar.layoutIfNeeded()
            }
        } else {
            self.navigationBar.subviews.forEach({ navBarView in
                guard let blurView = navBarView as? UIVisualEffectView else { return }
                UIView.animate(withDuration: 0.2) {
                    if invisible {
                        blurView.effect = nil
                        blurView.backgroundColor = .clear
                    } else {
                        blurView.effect = UIBlurEffect(style: .light)
                        blurView.backgroundColor = .init(white: 1.0, alpha: 0.6)
                    }
                }
            })
        }
    }
}
