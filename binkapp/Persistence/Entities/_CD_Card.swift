// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CD_Card.swift instead.

import Foundation
import CoreData

public enum CD_CardAttributes: String {
    case barcode = "barcode"
    case barcodeType = "barcodeType"
    case colour = "colour"
    case id = "id"
}

public enum CD_CardRelationships: String {
    case membershipCards = "membershipCards"
}

open class _CD_Card: NSManagedObject {

    // MARK: - Class methods

    open class func entityName () -> String {
        return "CD_Card"
    }

    open class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    @nonobjc
    open class func fetchRequest() -> NSFetchRequest<CD_Card> {
        return NSFetchRequest(entityName: self.entityName())
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _CD_Card.entity(managedObjectContext: managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var barcode: String?

    @NSManaged open
    var barcodeType: NSNumber?

    @NSManaged open
    var colour: String?

    @NSManaged open
    var id: String!

    // MARK: - Relationships

    @NSManaged open
    var membershipCards: NSSet

    open func membershipCardsSet() -> NSMutableSet {
        return self.membershipCards.mutableCopy() as! NSMutableSet
    }

}

extension _CD_Card {

    open func addMembershipCards(_ objects: NSSet) {
        let mutable = self.membershipCards.mutableCopy() as! NSMutableSet
        mutable.union(objects as Set<NSObject>)
        self.membershipCards = mutable.copy() as! NSSet
    }

    open func removeMembershipCards(_ objects: NSSet) {
        let mutable = self.membershipCards.mutableCopy() as! NSMutableSet
        mutable.minus(objects as Set<NSObject>)
        self.membershipCards = mutable.copy() as! NSSet
    }

    open func addMembershipCardsObject(_ value: CD_MembershipCard) {
        let mutable = self.membershipCards.mutableCopy() as! NSMutableSet
        mutable.add(value)
        self.membershipCards = mutable.copy() as! NSSet
    }

    open func removeMembershipCardsObject(_ value: CD_MembershipCard) {
        let mutable = self.membershipCards.mutableCopy() as! NSMutableSet
        mutable.remove(value)
        self.membershipCards = mutable.copy() as! NSSet
    }

}

