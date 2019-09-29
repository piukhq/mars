// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CD_PaymentCardMembershipCard.swift instead.

import Foundation
import CoreData

public enum CD_PaymentCardMembershipCardAttributes: String {
    case activeLink = "activeLink"
}

public enum CD_PaymentCardMembershipCardRelationships: String {
    case paymentCard = "paymentCard"
}

open class _CD_PaymentCardMembershipCard: CD_BaseObject {

    // MARK: - Class methods

    override open class func entityName () -> String {
        return "CD_PaymentCardMembershipCard"
    }

    override open class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    @nonobjc
    open class func fetchRequest() -> NSFetchRequest<CD_PaymentCardMembershipCard> {
        return NSFetchRequest(entityName: self.entityName())
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _CD_PaymentCardMembershipCard.entity(managedObjectContext: managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var activeLink: NSNumber?

    // MARK: - Relationships

    @NSManaged open
    var paymentCard: CD_PaymentCard?

}

