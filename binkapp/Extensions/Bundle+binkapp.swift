//
//  Bundle+binkapp.swift
//  binkapp
//
//  Created by Pop Dorin on 06/11/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

enum VersionComponent: Int {
    case major
    case minor
    case patch
    
    static func components(from versionString: String, expecting: [VersionComponent] = [.major, .minor, .patch]) -> [String]? {
        let components = versionString.components(separatedBy: ".")
        guard components.count == expecting.count else { return nil }
        return components
    }
    
    static func value(component: VersionComponent, from components: [String]) -> Int? {
        return Int(components[component.rawValue])
    }
}

extension Bundle {
    static let shortVersionNumber = main.infoDictionary?["CFBundleShortVersionString"] as? String
    static let bundleVersion = main.infoDictionary?["CFBundleVersion"] as? String

    static let majorVersion: Int? = {
        guard let components = versionComponents else { return nil }
        return VersionComponent.value(component: .major, from: components)
    }()

    static let minorVersion: Int? = {
        guard let components = versionComponents else { return nil }
        return VersionComponent.value(component: .minor, from: components)
    }()

    static let patchVersion: Int? = {
        guard let components = versionComponents else { return nil }
        return VersionComponent.value(component: .patch, from: components)
    }()

    private static let versionComponents = VersionComponent.components(from: shortVersionNumber ?? "", expecting: [.major, .minor, .patch])
}
