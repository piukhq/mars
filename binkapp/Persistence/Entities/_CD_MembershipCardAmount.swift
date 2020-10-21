// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CD_MembershipCardAmount.swift instead.

// swiftlint:disable all

// swiftlint:disable all

import Foundation
import CoreData

public enum CD_MembershipCardAmountAttributes: String {
    case currency = "currency"
    case prefix = "prefix"
    case suffix = "suffix"
    case value = "value"
}

public enum CD_MembershipCardAmountRelationships: String {
    case transaction = "transaction"
}

open class _CD_MembershipCardAmount: CD_BaseObject {

    // MARK: - Class methods

    override open class func entityName () -> String {
        return "CD_MembershipCardAmount"
    }

    override open class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    @nonobjc
    open class func fetchRequest() -> NSFetchRequest<CD_MembershipCardAmount> {
        return NSFetchRequest(entityName: self.entityName())
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _CD_MembershipCardAmount.entity(managedObjectContext: managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var currency: String?

    @NSManaged open
    var prefix: String?

    @NSManaged open
    var suffix: String?

    @NSManaged open
    var value: NSNumber?

    // MARK: - Relationships

    @NSManaged open
    var transaction: CD_MembershipTransaction?

}

