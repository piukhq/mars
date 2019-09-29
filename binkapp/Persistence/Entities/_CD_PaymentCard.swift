// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CD_PaymentCard.swift instead.

import Foundation
import CoreData

public enum CD_PaymentCardAttributes: String {
    case activeLink = "activeLink"
}

public enum CD_PaymentCardRelationships: String {
    case membershipCard = "membershipCard"
}

open class _CD_PaymentCard: CD_BaseObject {

    // MARK: - Class methods

    override open class func entityName () -> String {
        return "CD_PaymentCard"
    }

    override open class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    @nonobjc
    open class func fetchRequest() -> NSFetchRequest<CD_PaymentCard> {
        return NSFetchRequest(entityName: self.entityName())
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _CD_PaymentCard.entity(managedObjectContext: managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var activeLink: NSNumber?

    // MARK: - Relationships

    @NSManaged open
    var membershipCard: CD_MembershipCard?

}

