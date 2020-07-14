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

class PermissionsUtility {
    
    // MARK: - Camera permissions
    
    enum MediaType {
        case video
    }
    
    enum AuthorizationStatus {
        case authorized
        case denied
        case notDetermined
    }
    
    static var videoCaptureIsAuthorized: Bool {
        return AVCaptureDevice.authorizationStatus(for: .video) == .authorized
    }
    
    static var videoCaptureIsDenied: Bool {
        return AVCaptureDevice.authorizationStatus(for: .video) == .denied
    }
    
    static func requestVideoCaptureAuthorization(completion: @escaping (Bool) -> Void) {
        
    }
}
