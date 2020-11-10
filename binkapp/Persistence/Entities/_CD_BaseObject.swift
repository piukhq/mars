// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CD_BaseObject.swift instead.

// swiftlint:disable all

import Foundation
import CoreData

public enum CD_BaseObjectAttributes: String {
    case id = "id"
}

open class _CD_BaseObject: NSManagedObject {

    // MARK: - Class methods

    open class func entityName () -> String {
        return "CD_BaseObject"
    }

    open class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    @nonobjc
    open class func fetchRequest() -> NSFetchRequest<CD_BaseObject> {
        return NSFetchRequest(entityName: self.entityName())
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _CD_BaseObject.entity(managedObjectContext: managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var id: String!

    // MARK: - Relationships

}

