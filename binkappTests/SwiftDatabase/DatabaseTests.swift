import XCTest
import CoreData
@testable import binkapp

// swiftlint:disable all

class DatabaseTests: XCTestCase {

    // MARK: - Setup

    static let db = Database(named: "TestDatabase", inBundle: Bundle(for: DatabaseTests.self))

    override func tearDown() {
        DatabaseTests.db.mainContext.deleteAll(TestEntity.self)
    }

    // MARK: - Tests

    func testEntityCanBeCreated() {
        checkDatabaseHasNo(TestEntity.self)

        let entity = TestEntity(context: DatabaseTests.db.mainContext)
        XCTAssertNotNil(entity, "Entity is initialised succesfully")

        let testName = "Test Name"
        entity.name = testName
        DatabaseTests.db.save()

        let exp = expectation(description: #function)
        var entry: TestEntity?

        DatabaseTests.db.performTask { context in
            entry = context.fetchWithID(TestEntity.self, id: entity.objectID) ?? nil
            exp.fulfill()
        }

        waitForExpectations(timeout: 5)

        XCTAssertNotNil(entry, "We had an entry returned")
        XCTAssertEqual(entity, entry, "The correct object was returned")
        XCTAssertEqual(entity.objectID, entry?.objectID, "The correct object was returned")
    }

    func testAllValuesCanBeReturned() {
        checkDatabaseHasNo(TestEntity.self)

        let numberOfEntitiesToInsert = 10
        add(numberOfEntitiesToInsert, TestEntity.self)

        let exp = expectation(description: #function)
        var entries: [TestEntity]?

        DatabaseTests.db.performTask { context in
            entries = context.fetchAll(TestEntity.self)
            exp.fulfill()
        }

        waitForExpectations(timeout: 5)

        XCTAssertEqual(numberOfEntitiesToInsert, entries?.count, "Entries returned correctly")
    }

    func testCountReturnsCorrectly() {
        checkDatabaseHasNo(TestEntity.self)

        let numberOfEntitiesToInsert = 10
        add(numberOfEntitiesToInsert, TestEntity.self)

        let exp = expectation(description: #function)
        var count: Int?

        DatabaseTests.db.performTask { context in
            count = context.countOfAll(TestEntity.self)
            exp.fulfill()
        }

        waitForExpectations(timeout: 5)

        XCTAssertEqual(numberOfEntitiesToInsert, count, "Entries counted correctly")
    }

    func testPerformOnBackgroundPropogatesToMainContext() {
        let exp1 = expectation(description: "\(#function)-1")
        let entityName = "background"

        DatabaseTests.db.performBackgroundTask { context in
            let entity = TestEntity(context: context)
            entity.name = entityName
            do {
                try context.save()
            } catch {
                XCTFail("Background context could not save")
            }
            exp1.fulfill()
        }

        waitForExpectations(timeout: 5)

        let exp2 = expectation(description: "\(#function)-2")
        var mainContextEntity: [TestEntity]?

        DatabaseTests.db.performTask { context in
            mainContextEntity = context.fetch(TestEntity.self, predicate: NSPredicate(format: "name == %@", entityName))
            exp2.fulfill()
        }

        waitForExpectations(timeout: 5)

        XCTAssertNotNil(mainContextEntity, "We have a value returned")
        XCTAssertEqual(1, mainContextEntity?.count, "We have our one value returned")
        XCTAssertEqual(entityName, mainContextEntity?.first?.name, "We have the correct entity returned")
    }

    func testThatMainContextItemCanBeAccessedOnABackgroundContext() {
        let exp1 = expectation(description: "\(#function)-1")
        let entityName = "MainInBackground"

        var originalMainEntity: TestEntity?

        DatabaseTests.db.performTask { context in
            originalMainEntity = TestEntity(context: context)
            originalMainEntity?.name = entityName
            try? context.save()
            exp1.fulfill()
        }

        waitForExpectations(timeout: 5)

        guard let mainEntity = originalMainEntity else {
            XCTFail("We do not have a safe mainEntity")
            return
        }

        var safeEntityName: String?
        var safeEntityID = mainEntity.objectID

        let exp2 = expectation(description: "\(#function)-2")

        DatabaseTests.db.performBackgroundTask(with: mainEntity) { context, safeEntity in
            guard let safeEntity = safeEntity else {
                XCTFail("We did not get an object returned")
                return // We have no safe object returned
            }

            safeEntityName = safeEntity.name
            safeEntityID = safeEntity.objectID
            exp2.fulfill()
        }

        waitForExpectations(timeout: 5)
        XCTAssertEqual(safeEntityID, mainEntity.objectID)
        XCTAssertEqual(entityName, safeEntityName)
    }
}

extension DatabaseTests {
    func checkDatabaseHasNo<T: NSManagedObject>(_ entity: T.Type) {
        let noEntities = DatabaseTests.db.mainContext.fetchAll(entity)
        XCTAssertEqual(noEntities.count, 0, "We have no entities in the database")
    }

    func add<T: NSManagedObject>(_ x: Int, _ entity: T.Type) {
        for _ in 0..<x {
            _ = T(context: DatabaseTests.db.mainContext)
        }
        DatabaseTests.db.save()
    }
}
