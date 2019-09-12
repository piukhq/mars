// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CD_Tier.swift instead.

import Foundation
import CoreData

public enum CD_TierAttributes: String {
    case id = "id"
    case name = "name"
    case tierDescription = "tierDescription"
}

public enum CD_TierRelationships: String {
    case planAccount = "planAccount"
}

open class _CD_Tier: NSManagedObject {

    // MARK: - Class methods

    open class func entityName () -> String {
        return "CD_Tier"
    }

    open class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    @nonobjc
    open class func fetchRequest() -> NSFetchRequest<CD_Tier> {
        return NSFetchRequest(entityName: self.entityName())
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _CD_Tier.entity(managedObjectContext: managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var id: String!

    @NSManaged open
    var name: String?

    @NSManaged open
    var tierDescription: String?

    // MARK: - Relationships

    @NSManaged open
    var planAccount: CD_MembershipPlanAccount?

}

