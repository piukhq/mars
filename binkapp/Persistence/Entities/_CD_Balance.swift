// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CD_Balance.swift instead.

// swiftlint:disable all

import Foundation
import CoreData

public enum CD_BalanceAttributes: String {
    case balanceDescription = "balanceDescription"
    case currency = "currency"
    case prefix = "prefix"
    case suffix = "suffix"
}

public enum CD_BalanceRelationships: String {
    case plan = "plan"
}

open class _CD_Balance: CD_BaseObject {

    // MARK: - Class methods

    override open class func entityName () -> String {
        return "CD_Balance"
    }

    override open class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    @nonobjc
    open class func fetchRequest() -> NSFetchRequest<CD_Balance> {
        return NSFetchRequest(entityName: self.entityName())
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _CD_Balance.entity(managedObjectContext: managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var balanceDescription: String?

    @NSManaged open
    var currency: String?

    @NSManaged open
    var prefix: String?

    @NSManaged open
    var suffix: String?

    // MARK: - Relationships

    @NSManaged open
    var plan: CD_MembershipPlan?

}

