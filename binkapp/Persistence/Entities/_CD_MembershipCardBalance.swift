// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CD_MembershipCardBalance.swift instead.

import Foundation
import CoreData

public enum CD_MembershipCardBalanceAttributes: String {
    case currency = "currency"
    case prefix = "prefix"
    case suffix = "suffix"
    case updatedAt = "updatedAt"
    case value = "value"
}

public enum CD_MembershipCardBalanceRelationships: String {
    case card = "card"
}

open class _CD_MembershipCardBalance: CD_BaseObject {

    // MARK: - Class methods

    override open class func entityName () -> String {
        return "CD_MembershipCardBalance"
    }

    override open class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    @nonobjc
    open class func fetchRequest() -> NSFetchRequest<CD_MembershipCardBalance> {
        return NSFetchRequest(entityName: self.entityName())
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _CD_MembershipCardBalance.entity(managedObjectContext: managedObjectContext) else { return nil }
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
    var updatedAt: NSNumber?

    @NSManaged open
    var value: NSNumber?

    // MARK: - Relationships

    @NSManaged open
    var card: CD_MembershipCard?

}

