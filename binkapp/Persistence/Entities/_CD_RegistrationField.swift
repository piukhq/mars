// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CD_RegistrationField.swift instead.

import Foundation
import CoreData

public enum CD_RegistrationFieldAttributes: String {
    case column = "column"
    case fieldDescription = "fieldDescription"
    case type = "type"
}

public enum CD_RegistrationFieldRelationships: String {
    case planAccount = "planAccount"
}

open class _CD_RegistrationField: CD_BaseObject {

    // MARK: - Class methods

    override open class func entityName () -> String {
        return "CD_RegistrationField"
    }

    override open class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    @nonobjc
    open class func fetchRequest() -> NSFetchRequest<CD_RegistrationField> {
        return NSFetchRequest(entityName: self.entityName())
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _CD_RegistrationField.entity(managedObjectContext: managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var column: String?

    @NSManaged open
    var fieldDescription: String?

    @NSManaged open
    var type: NSNumber?

    // MARK: - Relationships

    @NSManaged open
    var planAccount: CD_MembershipPlanAccount?

}

