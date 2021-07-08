//
//  FileManager+Extension.swift
//  binkapp
//
//  Created by Sean Williams on 28/06/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import Foundation

extension FileManager {
    static func sharedContainerURL() -> URL? {
        guard let sharedContainer = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.bink.wallet") else { return nil }
        return sharedContainer
    }
}
