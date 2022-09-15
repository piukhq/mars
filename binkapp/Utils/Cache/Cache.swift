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
    static let geoLocationsDataCache = NSCache<NSString, NSData>()
    
    static func clearAll() {
        Cache.sharedImageCache.removeAllObjects()
    }
}
