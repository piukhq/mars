//
//  NSPersistentContainer.swift
//  Max Woodhams
//
//  Created by Max Woodhams on 03/04/2019.
//  Copyright © 2019 Max Woodhams. All rights reserved.
//

import CoreData

extension NSPersistentContainer {
    /// An empty implementation allowing a lazy instance to initialise. Since the loading of
    /// persistent stores is async we want to trigger it immediately instead of waiting for our
    /// first query to execute. This triggers the lazy var to be built and the persistent stores
    /// to be loaded.
    func prepare() {}
}
