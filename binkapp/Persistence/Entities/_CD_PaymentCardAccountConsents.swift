// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CD_PaymentCardAccountConsents.swift instead.

import Foundation
import CoreData

public enum CD_PaymentCardAccountConsentsAttributes: String {
    case timestamp = "timestamp"
    case type = "type"
}

public enum CD_PaymentCardAccountConsentsRelationships: String {
    case account = "account"
}

open class _CD_PaymentCardAccountConsents: CD_BaseObject {

    // MARK: - Class methods

    override open class func entityName () -> String {
        return "CD_PaymentCardAccountConsents"
    }

    override open class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    @nonobjc
    open class func fetchRequest() -> NSFetchRequest<CD_PaymentCardAccountConsents> {
        return NSFetchRequest(entityName: self.entityName())
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _CD_PaymentCardAccountConsents.entity(managedObjectContext: managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var timestamp: NSNumber?

    @NSManaged open
    var type: NSNumber?

    // MARK: - Relationships

    @NSManaged open
    var account: CD_PaymentCardAccount?

}

