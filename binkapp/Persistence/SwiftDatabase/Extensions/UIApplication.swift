//
//  UIApplication.swift
//  SwiftDatabase
//
//  Created by Max Woodhams on 18/08/2019.
//  Copyright © 2019 Max Woodhams. All rights reserved.
//

import UIKit

public extension UIApplication {
    static var isRunningUnitTests: Bool {
        return ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
    }
    
    static var isRunningUITests: Bool {
        return CommandLine.arguments.contains("UI-testing")
    }
    
    static let bottomSafeArea: CGFloat = {
        let window = UIApplication.shared.connectedScenes.flatMap { ($0 as? UIWindowScene)?.windows ?? [] }.first { $0.isKeyWindow }
        return window?.safeAreaInsets.bottom ?? 0
    }()
}
