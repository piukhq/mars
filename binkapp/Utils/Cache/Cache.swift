//
//  Cache.swift
//  binkapp
//
//  Created by Nick Farrant on 27/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import UIKit

enum Cache {
    static let sharedImageCache = NSCache<NSString, UIImage>()
    static let geoLocationsDataCache = NSCache<NSString, DataCache>()
    
    static func clearAll() {
        Cache.sharedImageCache.removeAllObjects()
    }
}

class DataCache: NSObject, NSDiscardableContent {
    public var cachedData: NSData?

    init(data: NSData) {
        self.cachedData = data
    }
    
    func beginContentAccess() -> Bool {
        return true
    }
    
    func isContentDiscarded() -> Bool {
        return false
    }

    func endContentAccess() {}
    func discardContentIfPossible() {}
}
