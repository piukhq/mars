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
}
