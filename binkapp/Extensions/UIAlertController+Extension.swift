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
        let alert = BinkAlertController(title: "Feature not implemented", message: nil, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(alertAction)
        vc.present(alert, animated: true, completion: nil)
    }
    
    static func cardScannerEnterManuallyAlertController(enterManuallyAction: @escaping () -> Void, addFromPhotoLibraryAction: @escaping () -> Void) -> BinkAlertController? {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return nil }
        
        let alert = BinkAlertController(title: L10n.cameraDeniedTitle, message: L10n.cameraDeniedBody, preferredStyle: .alert)
        let allowAction = UIAlertAction(title: L10n.cameraDeniedAllowAccess, style: .default, handler: { _ in
            UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
        })
        let enterManuallyAction = UIAlertAction(title: L10n.cameraDeniedManuallyOption, style: .default) { _ in
            enterManuallyAction()
        }
        let addFromPhotoLibraryAction = UIAlertAction(title: L10n.loyaltyScannerAddPhotoFromLibraryButtonTitle, style: .default) { _ in
            addFromPhotoLibraryAction()
        }
        
        alert.addAction(enterManuallyAction)
        alert.addAction(allowAction)
        alert.addAction(addFromPhotoLibraryAction)
        alert.addAction(UIAlertAction(title: L10n.cancel, style: .cancel, handler: nil))
        
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
