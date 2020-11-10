//
//  StorageUtilityMock.swift
//  binkapp
//
//  Created by Nick Farrant on 31/01/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import Foundation
import DeepDiff

// swiftlint:disable convenience_type
class StorageUtilityMock {
    static var sharedStoredObjects: [StoredObject] = []

    enum ExpiryPolicy: Int, Codable {
        case week = 7
        case month = 30
        case year = 365
    }

    struct StoredObject: Codable {
        let objectPath: String
        let storedDate: Date
        let policy: ExpiryPolicy

        var isExpired: Bool {
            return expiryDate < Date()
        }

        private var expiryDate: Date {
            return Calendar.current.date(byAdding: .day, value: +policy.rawValue, to: storedDate) ?? Date()
        }
    }

    static func addStoredObject(_ object: StoredObject) {
        // Check we aren't already storing this object
        let storedObjectPaths = sharedStoredObjects.map {
            $0.objectPath
        }
        guard !storedObjectPaths.contains(object.objectPath) else { return }
        sharedStoredObjects.append(object)
    }

    static func purgeExpiredStoredObjects() {
        let validStoredObjects = sharedStoredObjects.filter { !$0.isExpired }
        sharedStoredObjects = validStoredObjects
    }

    static func refreshPlanImages() {
        // Get urls from plan images
        let planImageUrls = [
            "abcde",
            "bcdef",
            "cdefg",
            "defgh",
            "efghi"
        ]

        // Get urls from stored objects
        let storedObjectUrls = sharedStoredObjects.map { $0.objectPath }

        // Diff two collections
        let changes = diff(old: storedObjectUrls, new: planImageUrls)

        // We are left with a collection of urls that were stored but not found in the latest plan refresh
        // These will be marked as deletions and can be removed
        let deletions = changes.compactMap {
            $0.delete
        }
        let deletionIds = deletions.map {
            $0.index
        }

        deletionIds.forEach {
            if sharedStoredObjects.indices.contains($0) {
                sharedStoredObjects.remove(at: $0)
            }
        }
    }
}
