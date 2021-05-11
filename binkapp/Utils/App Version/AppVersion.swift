//
//  AppVersion.swift
//  binkapp
//
//  Created by Nick Farrant on 10/05/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import Foundation

class AppVersion {
    let major: Int?
    let minor: Int?
    let patch: Int?
    
    lazy var versionString = readableVersionString
    
    enum VersionComponent: Int, CaseIterable {
        case major
        case minor
        case patch
    }
    
    init?(versionString: String) {
        /// Only accept the components matching our supported Version Components
        let components = Array(versionString.components(separatedBy: ".").prefix(VersionComponent.allCases.count))
        
        /// We must be able to atleast parse a major number from the version string, otherwise return nil
        guard let major = components[safe: VersionComponent.major.rawValue]?.toInt() else { return nil }
        self.major = major
        
        self.minor = components[safe: VersionComponent.minor.rawValue]?.toInt()
        self.patch = components[safe: VersionComponent.patch.rawValue]?.toInt()
    }
    
    private lazy var readableVersionString: String = {
        var readableVersionString: [String] = []
        let components = [major, minor, patch]
        components.forEach { component in
            guard let component = component else { return }
            readableVersionString.append("\(component)")
        }
        return readableVersionString.joined(separator: ".")
    }()
    
    func isMoreRecentThanVersion(_ version: AppVersion) -> Bool {
        /// If comparison major is lower, return true
        /// If comparison major is higher, return false
        guard let comparisonMajor = version.major, let major = self.major else { return false }
        if major > comparisonMajor { return true }
        if comparisonMajor > major { return false }
        /// If comparison major is the same, move to minor
        
        /// If comparison minor is lower, return true
        /// If comparison minor is higher, return false
        guard let comparisonMinor = version.minor, let minor = self.minor else { return false }
        if minor > comparisonMinor { return true }
        if comparisonMinor > minor { return false }
        /// If comparison minor is the same, move to patch
        
        /// If comparison patch is lower, return true
        /// If comparison patch is higher, return false
        guard let comparisonPatch = version.patch, let patch = self.patch else { return false }
        if patch > comparisonPatch { return true }
        if comparisonPatch > patch { return false }
        
        /// If comparison patch is the same, return false
        return false
    }
}
