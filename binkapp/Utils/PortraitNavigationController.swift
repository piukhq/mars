//
//  PortraitNavigationController.swift
//  binkapp
//
//  Created by Paul Tiriteu on 10/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class PortraitNavigationController: UINavigationController {
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewControllers.forEach { $0.navigationItem.backBarButtonItem = nullBackButton() }
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        super.pushViewController(viewController, animated: animated)
        
        viewController.navigationItem.backBarButtonItem = nullBackButton()
    }
    
    private func nullBackButton() -> UIBarButtonItem {
        return UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
}
