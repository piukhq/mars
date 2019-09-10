// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CD_AddField.swift instead.

import Foundation
import CoreData

public enum CD_AddFieldAttributes: String {
    case column = "column"
    case fieldDescription = "fieldDescription"
    case id = "id"
    case type = "type"
    case validation = "validation"
}

open class _CD_AddField: NSManagedObject {

    // MARK: - Class methods

    open class func entityName () -> String {
        return "CD_AddField"
    }

    open class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    @nonobjc
    open class func fetchRequest() -> NSFetchRequest<CD_AddField> {
        return NSFetchRequest(entityName: self.entityName())
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _CD_AddField.entity(managedObjectContext: managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var column: String?

    @NSManaged open
    var fieldDescription: String?

    @NSManaged open
    var id: String!

    @NSManaged open
    var type: NSNumber?

    @NSManaged open
    var validation: String?

    // MARK: - Relationships

}

