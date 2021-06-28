//
//  FileManager+Extension.swift
//  binkapp
//
//  Created by Sean Williams on 28/06/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import Foundation

extension FileManager {
    static func sharedContainerURL() -> URL {
        return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.bink.wallet")!
    }
}
