//
//  UIAlertController+Extension.swift
//  binkapp
//
//  Created by Max Woodhams on 12/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

extension UIAlertController {
    static func presentFeatureNotImplementedAlert(on vc: UIViewController) {
        let alert = UIAlertController(title: "Feature not implemented", message: nil, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(alertAction)
        vc.present(alert, animated: true, completion: nil)
    }
}

