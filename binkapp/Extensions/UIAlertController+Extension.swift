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
    
    static func cardScannerEnterManuallyAlertController(enterManuallyAction: @escaping () -> Void) -> UIAlertController? {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return nil }
        
        let alert = UIAlertController(title: "camera_denied_title".localized, message: "camera_denied_body".localized, preferredStyle: .alert)
        let allowAction = UIAlertAction(title: "camera_denied_allow_access".localized, style: .default, handler: { _ in
            UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
        })
        let enterManuallyAction = UIAlertAction(title: "camera_denied_manually_option".localized, style: .default) { _ in
            enterManuallyAction()
        }
        alert.addAction(enterManuallyAction)
        alert.addAction(allowAction)
        alert.addAction(UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil))
        
        return alert
    }
    
    /// Fixes iOS bug where subview is set to -16 when animated
    func pruneNegativeWidthConstraints() {
        for subView in self.view.subviews {
            for constraint in subView.constraints where constraint.debugDescription.contains("width == - 16") {
                subView.removeConstraint(constraint)
            }
        }
    }
}
