// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CD_MembershipCardImage.swift instead.
// swiftlint:disable all


import Foundation
import CoreData

public enum CD_MembershipCardImageAttributes: String {
    case encoding = "encoding"
    case imageDescription = "imageDescription"
    case type = "type"
}

public enum CD_MembershipCardImageRelationships: String {
    case membershipCards = "membershipCards"
}

open class _CD_MembershipCardImage: CD_BaseImage {

    // MARK: - Class methods

    override open class func entityName () -> String {
        return "CD_MembershipCardImage"
    }

    override open class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    @nonobjc
    open class func fetchRequest() -> NSFetchRequest<CD_MembershipCardImage> {
        return NSFetchRequest(entityName: self.entityName())
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _CD_MembershipCardImage.entity(managedObjectContext: managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var encoding: String?

    @NSManaged open
    var imageDescription: String?

    @NSManaged open
    var type: NSNumber?

    // MARK: - Relationships

    @NSManaged open
    var membershipCards: NSSet

    open func membershipCardsSet() -> NSMutableSet {
        return self.membershipCards.mutableCopy() as! NSMutableSet
    }

}

extension _CD_MembershipCardImage {

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

