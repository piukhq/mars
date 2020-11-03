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
