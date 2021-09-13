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
    var isSmallSize: Bool {
        switch width {
        case .iPhoneSESize, .iPhone5Size, .iPhone12MiniSize:
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
        case iPhone11ProMaxSize = "iPhone XS Max or iPhone 11 Pro Max"
        case iPhone11ProSize = "iPhone 11 Pro"
        case iPhone12MiniSize = "iPhone 12 Mini"
        case iPhone12Size = "iPhone 12 or iPhone 12 Pro"
        case iPhone12ProMaxSize = "iPhone 12 Pro Max"
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
        case 2340:
            return .iPhone12MiniSize
        case 2436:
            return .iPhone11ProSize
        case 2688:
            return .iPhone11ProMaxSize
        case 2778:
            return .iPhone12ProMaxSize
        default:
            return .unknown
        }
    }
    
    var width: ScreenSize {
        switch UIScreen.main.bounds.width {
        case 320:
            return .iPhone5Size
        case 360:
            return .iPhone12MiniSize
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

extension UIApplication {
    static let bottomSafeArea: CGFloat = {
        let window = UIApplication.shared.windows.first { $0.isKeyWindow }
        return window?.safeAreaInsets.bottom ?? 0
    }()
}
