// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CD_FieldChoice.swift instead.

// swiftlint:disable all

import Foundation
import CoreData

public enum CD_FieldChoiceAttributes: String {
    case value = "value"
}

public enum CD_FieldChoiceRelationships: String {
    case addField = "addField"
    case authoriseField = "authoriseField"
    case enrolField = "enrolField"
    case registrationField = "registrationField"
}

open class _CD_FieldChoice: CD_BaseObject {

    // MARK: - Class methods

    override open class func entityName () -> String {
        return "CD_FieldChoice"
    }

    override open class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    @nonobjc
    open class func fetchRequest() -> NSFetchRequest<CD_FieldChoice> {
        return NSFetchRequest(entityName: self.entityName())
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _CD_FieldChoice.entity(managedObjectContext: managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var value: String?

    // MARK: - Relationships

    @NSManaged open
    var addField: CD_AddField?

    @NSManaged open
    var authoriseField: CD_AuthoriseField?

    @NSManaged open
    var enrolField: CD_EnrolField?

    @NSManaged open
    var registrationField: CD_RegistrationField?

}

