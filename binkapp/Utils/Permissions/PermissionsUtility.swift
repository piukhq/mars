//
//  PermissionsUtility.swift
//  binkapp
//
//  Created by Nick Farrant on 14/07/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import Foundation
import AVKit
import AVFoundation
import UIKit
import CardScan

enum PermissionsUtility {
    // MARK: - Camera permissions
    
    static var videoCaptureIsAuthorized: Bool {
        return AVCaptureDevice.authorizationStatus(for: .video) == .authorized
    }
    
    static var videoCaptureIsDenied: Bool {
        return AVCaptureDevice.authorizationStatus(for: .video) == .denied
    }
    
    static func requestVideoCaptureAuthorization(completion: @escaping (Bool) -> Void) {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
}

extension PermissionsUtility {
    static func launchLoyaltyScanner(_ viewController: BarcodeScannerViewController, grantedAction: @escaping EmptyCompletionBlock, enterManuallyAction: EmptyCompletionBlock? = nil) {
        launchScanner(viewController: viewController, grantedAction: grantedAction, enterManuallyAction: enterManuallyAction)
    }

    static func launchPaymentScanner(_ viewController: ScanViewController, grantedAction: @escaping EmptyCompletionBlock, enterManuallyAction: EmptyCompletionBlock? = nil) {
        launchScanner(viewController: viewController, grantedAction: grantedAction, enterManuallyAction: enterManuallyAction)
    }

    private static func launchScanner(viewController: UIViewController, grantedAction: @escaping EmptyCompletionBlock, enterManuallyAction: EmptyCompletionBlock? = nil) {
        let enterManuallyAlert = BinkAlertController.cardScannerEnterManuallyAlertController {
            enterManuallyAction?()
        }

        if PermissionsUtility.videoCaptureIsAuthorized {
            grantedAction()
        } else if PermissionsUtility.videoCaptureIsDenied {
            if let alert = enterManuallyAlert {
                let navigationRequest = AlertNavigationRequest(alertController: alert)
                Current.navigate.to(navigationRequest)
            }
        } else {
            PermissionsUtility.requestVideoCaptureAuthorization { granted in
                if granted {
                    grantedAction()
                } else {
                    if let alert = enterManuallyAlert {
                        let navigationRequest = AlertNavigationRequest(alertController: alert)
                        Current.navigate.to(navigationRequest)
                    }
                }
            }
        }
    }
}
