//
//  UIDeviceExtension.swift
//  binkapp
//
//  Created by Nick Farrant on 09/01/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

// swiftlint:disable discouraged_direct_init

import UIKit

extension UIDevice {
    var hasNotch: Bool {
        let window = UIApplication.shared.windows.first { $0.isKeyWindow }
        let bottom = window?.safeAreaInsets.bottom ?? 0
        return bottom > 0
    }
    
    var iPhoneX: Bool { UIScreen.main.nativeBounds.height == 2436 }
    var iPhone: Bool { UIDevice.current.userInterfaceIdiom == .phone }
    var iPad: Bool { UIDevice().userInterfaceIdiom == .pad }
    var iPhoneSE: Bool {
        switch width {
        case .iPhoneSESize, .iPhone5Size:
            return true
        default:
            return false
        }
    }
    
    enum ScreenSize: String {
        case iPhone4Size = "iPhone 4 or iPhone 4S"
        case iPhone5Size = "iPhone 5, iPhone 5s, iPhone 5c"
        case iPhoneSESize = "iPhone 6, iPhone 6S, iPhone 7, iPhone 8 or iPhone SE"
        case iPhonePlusSize = "iPhone 6 Plus, iPhone 6S Plus, iPhone 7 Plus or iPhone 8 Plus"
        case iPhoneXSize = "iPhone X or iPhone XS"
        case iPhone11Size = "iPhone XR or iPhone 11"
        case iPhoneMaxSize = "iPhone XS Max or iPhone Pro Max"
        case iPhone11ProSize = "iPhone 11 Pro"
        case iPhone12Size = "iPhone 12"
        case unknown
    }
    
    var height: ScreenSize {
        switch UIScreen.main.nativeBounds.height {
        case 1136:
            return .iPhone5Size
        case 1334:
            return .iPhoneSESize
        case 1792:
            return .iPhone11Size
        case 1920, 2208:
            return .iPhonePlusSize
        case 2426:
            return .iPhone11ProSize
        case 2436:
            return .iPhoneXSize
        case 2688:
            return .iPhoneMaxSize
        default:
            return .unknown
        }
    }
    
    var width: ScreenSize {
        switch UIScreen.main.bounds.width {
        case 320:
            return .iPhone5Size
        case 375:
            return .iPhoneSESize
        case 414:
            return .iPhonePlusSize
        case 390:
            return .iPhone12Size
        default:
            return .unknown
        }
    }
}
