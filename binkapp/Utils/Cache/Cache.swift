//
//  Cache.swift
//  binkapp
//
//  Created by Nick Farrant on 27/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import UIKit

class Cache {
    static let sharedImageCache = NSCache<NSString, UIImage>()

    static func clearAll() {
        Cache.sharedImageCache.removeAllObjects()
    }
}
