//
//  Bundle+binkapp.swift
//  binkapp
//
//  Created by Pop Dorin on 06/11/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

extension Bundle {
    static let shortVersionNumber = main.infoDictionary?["CFBundleShortVersionString"] as? String
    static let bundleVersion = main.infoDictionary?["CFBundleVersion"] as? String

    static let majorVersion: Int? = {
        guard let components = versionComponents else { return nil }
        return Int(components[0])
    }()

    static let minorVersion: Int? = {
        guard let components = versionComponents else { return nil }
        return Int(components[1])
    }()

    static let patchVersion: Int? = {
        guard let components = versionComponents else { return nil }
        return Int(components[2])
    }()

    private static let versionComponents = shortVersionNumber?.components(separatedBy: ".")
}
