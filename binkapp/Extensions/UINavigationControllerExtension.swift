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
}
