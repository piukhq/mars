//
//  StorageUtilityTests.swift
//  binkappTests
//
//  Created by Nick Farrant on 31/01/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import XCTest
@testable import binkapp

class StorageUtilityTests: XCTestCase {

    override func setUp() {
        StorageUtilityMock.sharedStoredObjects = [StorageUtilityMock.StoredObject]()
    }

    func test_addStoredObject_addsObjectThatDoesNotExist() {
        StorageUtilityMock.addStoredObject(StorageUtilityMock.StoredObject(objectPath: "abcde", storedDate: Date(), policy: .week))

        XCTAssertEqual(StorageUtilityMock.sharedStoredObjects.count, 1)
    }

    func test_addStoredObject_doesNotAddObjectThatAlreadyExists() {
        StorageUtilityMock.addStoredObject(StorageUtilityMock.StoredObject(objectPath: "abcde", storedDate: Date(), policy: .week))

        XCTAssertEqual(StorageUtilityMock.sharedStoredObjects.count, 1)

        StorageUtilityMock.addStoredObject(StorageUtilityMock.StoredObject(objectPath: "abcde", storedDate: Date(), policy: .week))

        XCTAssertEqual(StorageUtilityMock.sharedStoredObjects.count, 1)
    }

    func test_purgeExpiredStoredObjects_removesExpiredObjects() {
        let expiredDate = Calendar.current.date(byAdding: .year, value: -10, to: Date())
        StorageUtilityMock.addStoredObject(StorageUtilityMock.StoredObject(objectPath: "abcde", storedDate: expiredDate!, policy: .week))
        StorageUtilityMock.addStoredObject(StorageUtilityMock.StoredObject(objectPath: "fghij", storedDate: expiredDate!, policy: .month))
        StorageUtilityMock.addStoredObject(StorageUtilityMock.StoredObject(objectPath: "klmno", storedDate: expiredDate!, policy: .year))

        StorageUtilityMock.addStoredObject(StorageUtilityMock.StoredObject(objectPath: "pqrst", storedDate: Date(), policy: .year))

        XCTAssertEqual(StorageUtilityMock.sharedStoredObjects.count, 4)

        StorageUtilityMock.purgeExpiredStoredObjects()

        XCTAssertEqual(StorageUtilityMock.sharedStoredObjects.count, 1)
    }

    func test_refreshPlanImages_deletesRedundantStoredObjects() {
        StorageUtilityMock.addStoredObject(StorageUtilityMock.StoredObject(objectPath: "a", storedDate: Date(), policy: .year))

        XCTAssertEqual(StorageUtilityMock.sharedStoredObjects.count, 1)

        StorageUtilityMock.refreshPlanImages()

        XCTAssertEqual(StorageUtilityMock.sharedStoredObjects.count, 0)
    }

    func test_refreshPlanImages_retainsValidObjects() {
        StorageUtilityMock.addStoredObject(StorageUtilityMock.StoredObject(objectPath: "abcde", storedDate: Date(), policy: .year))

        XCTAssertEqual(StorageUtilityMock.sharedStoredObjects.count, 1)

        StorageUtilityMock.refreshPlanImages()

        XCTAssertEqual(StorageUtilityMock.sharedStoredObjects.count, 1)
    }

}
