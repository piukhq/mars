// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CD_PaymentCard.swift instead.

import Foundation
import CoreData

public enum CD_PaymentCardAttributes: String {
    case status = "status"
}

public enum CD_PaymentCardRelationships: String {
    case account = "account"
    case card = "card"
    case linkedMembershipCards = "linkedMembershipCards"
}

open class _CD_PaymentCard: CD_CardAccount {

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
    var status: String?

    // MARK: - Relationships

    @NSManaged open
    var account: CD_PaymentCardAccount?

    @NSManaged open
    var card: CD_PaymentCardCard?

    @NSManaged open
    var linkedMembershipCards: NSSet

    open func linkedMembershipCardsSet() -> NSMutableSet {
        return self.linkedMembershipCards.mutableCopy() as! NSMutableSet
    }

}

extension _CD_PaymentCard {

    open func addLinkedMembershipCards(_ objects: NSSet) {
        let mutable = self.linkedMembershipCards.mutableCopy() as! NSMutableSet
        mutable.union(objects as Set<NSObject>)
        self.linkedMembershipCards = mutable.copy() as! NSSet
    }

    open func removeLinkedMembershipCards(_ objects: NSSet) {
        let mutable = self.linkedMembershipCards.mutableCopy() as! NSMutableSet
        mutable.minus(objects as Set<NSObject>)
        self.linkedMembershipCards = mutable.copy() as! NSSet
    }

    open func addLinkedMembershipCardsObject(_ value: CD_MembershipCard) {
        let mutable = self.linkedMembershipCards.mutableCopy() as! NSMutableSet
        mutable.add(value)
        self.linkedMembershipCards = mutable.copy() as! NSSet
    }

    open func removeLinkedMembershipCardsObject(_ value: CD_MembershipCard) {
        let mutable = self.linkedMembershipCards.mutableCopy() as! NSMutableSet
        mutable.remove(value)
        self.linkedMembershipCards = mutable.copy() as! NSSet
    }

}

