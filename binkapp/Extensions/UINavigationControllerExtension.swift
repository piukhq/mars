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
        let blurEffect = Styling.barBlur(for: traitCollection)
        let color = Styling.Colors.tabBar
        
        self.navigationBar.standardAppearance.backgroundEffect = visible ? blurEffect : nil
        self.navigationBar.standardAppearance.backgroundColor = visible ? color : .clear
        
        self.navigationBar.scrollEdgeAppearance?.backgroundEffect = visible ? blurEffect : nil
        self.navigationBar.scrollEdgeAppearance?.backgroundColor = visible ? color : .clear
        if animated {
            UIView.animate(withDuration: animationDuration) {
                self.navigationBar.layoutIfNeeded()
            }
        }
    }
}
