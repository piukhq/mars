// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CD_MembershipCardAccount.swift instead.

import Foundation
import CoreData

public enum CD_MembershipCardAccountAttributes: String {
    case id = "id"
    case tier = "tier"
}

public enum CD_MembershipCardAccountRelationships: String {
    case membershipCard = "membershipCard"
}

open class _CD_MembershipCardAccount: NSManagedObject {

    // MARK: - Class methods

    open class func entityName () -> String {
        return "CD_MembershipCardAccount"
    }

    open class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    @nonobjc
    open class func fetchRequest() -> NSFetchRequest<CD_MembershipCardAccount> {
        return NSFetchRequest(entityName: self.entityName())
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _CD_MembershipCardAccount.entity(managedObjectContext: managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var id: String!

    @NSManaged open
    var tier: NSNumber?

    // MARK: - Relationships

    @NSManaged open
    var membershipCard: CD_MembershipCard?

}

