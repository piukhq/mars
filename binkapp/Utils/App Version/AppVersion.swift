//
//  AppVersion.swift
//  binkapp
//
//  Created by Nick Farrant on 10/05/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import Foundation

struct AppVersion {
    let versionString: String
    let major: Int?
    let minor: Int?
    let patch: Int?
    
    enum VersionComponent: Int {
        case major
        case minor
        case patch
    }
    
    init?(versionString: String?) {
        guard let versionString = versionString else { return nil }
        let components = versionString.components(separatedBy: ".")
        self.versionString = versionString
        self.major = components[safe: VersionComponent.major.rawValue]?.toInt()
        self.minor = components[safe: VersionComponent.minor.rawValue]?.toInt()
        self.patch = components[safe: VersionComponent.patch.rawValue]?.toInt()
    }
    
    var isMoreRecentThanCurrentVersion: Bool {
        /// If current major is lower, return true
        /// If current major is higher, return fals
        guard let currentMajor = Bundle.currentVersion?.major, let major = self.major else { return false }
        if major > currentMajor { return true }
        if currentMajor > major { return false }
        /// If current major is the same, move to minor
        
        /// If current minor is lower, return true
        /// If current minor is higher, return false
        guard let currentMinor = Bundle.currentVersion?.minor, let minor = self.minor else { return false }
        if minor > currentMinor { return true }
        if currentMinor > minor { return false }
        /// If current minor is the same, move to patch
        
        /// If current patch is lower, return true
        /// If current patch is higher, return false
        guard let currentPatch = Bundle.currentVersion?.patch, let patch = self.patch else { return false }
        if patch > currentPatch { return true }
        if currentPatch > patch { return false }
        
        /// If current patch is the same, return false
        return false
    }
}
