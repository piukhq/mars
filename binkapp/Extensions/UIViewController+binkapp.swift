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
}
