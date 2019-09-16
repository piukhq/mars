// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CD_ReasonCode.swift instead.

import Foundation
import CoreData

public enum CD_ReasonCodeAttributes: String {
    case codeDescription = "codeDescription"
    case codeString = "codeString"
    case id = "id"
    case value = "value"
}

public enum CD_ReasonCodeRelationships: String {
    case status = "status"
}

open class _CD_ReasonCode: NSManagedObject {

    // MARK: - Class methods

    open class func entityName () -> String {
        return "CD_ReasonCode"
    }

    open class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    @nonobjc
    open class func fetchRequest() -> NSFetchRequest<CD_ReasonCode> {
        return NSFetchRequest(entityName: self.entityName())
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _CD_ReasonCode.entity(managedObjectContext: managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var codeDescription: String?

    @NSManaged open
    var codeString: String?

    @NSManaged open
    var id: String!

    @NSManaged open
    var value: NSNumber?

    // MARK: - Relationships

    @NSManaged open
    var status: CD_MembershipCardStatus?

}

