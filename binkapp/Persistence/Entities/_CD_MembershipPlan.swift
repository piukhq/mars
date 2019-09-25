// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CD_MembershipPlan.swift instead.

import Foundation
import CoreData

public enum CD_MembershipPlanAttributes: String {
    case id = "id"
    case status = "status"
}

public enum CD_MembershipPlanRelationships: String {
    case account = "account"
    case balances = "balances"
    case featureSet = "featureSet"
    case images = "images"
    case membershipCards = "membershipCards"
}

open class _CD_MembershipPlan: NSManagedObject {

    // MARK: - Class methods

    open class func entityName () -> String {
        return "CD_MembershipPlan"
    }

    open class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    @nonobjc
    open class func fetchRequest() -> NSFetchRequest<CD_MembershipPlan> {
        return NSFetchRequest(entityName: self.entityName())
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _CD_MembershipPlan.entity(managedObjectContext: managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var id: String!

    @NSManaged open
    var status: String?

    // MARK: - Relationships

    @NSManaged open
    var account: CD_MembershipPlanAccount?

    @NSManaged open
    var balances: NSSet

    open func balancesSet() -> NSMutableSet {
        return self.balances.mutableCopy() as! NSMutableSet
    }

    @NSManaged open
    var featureSet: CD_FeatureSet?

    @NSManaged open
    var images: NSSet

    open func imagesSet() -> NSMutableSet {
        return self.images.mutableCopy() as! NSMutableSet
    }

    @NSManaged open
    var membershipCards: NSSet

    open func membershipCardsSet() -> NSMutableSet {
        return self.membershipCards.mutableCopy() as! NSMutableSet
    }

}

extension _CD_MembershipPlan {

    open func addBalances(_ objects: NSSet) {
        let mutable = self.balances.mutableCopy() as! NSMutableSet
        mutable.union(objects as Set<NSObject>)
        self.balances = mutable.copy() as! NSSet
    }

    open func removeBalances(_ objects: NSSet) {
        let mutable = self.balances.mutableCopy() as! NSMutableSet
        mutable.minus(objects as Set<NSObject>)
        self.balances = mutable.copy() as! NSSet
    }

    open func addBalancesObject(_ value: CD_Balance) {
        let mutable = self.balances.mutableCopy() as! NSMutableSet
        mutable.add(value)
        self.balances = mutable.copy() as! NSSet
    }

    open func removeBalancesObject(_ value: CD_Balance) {
        let mutable = self.balances.mutableCopy() as! NSMutableSet
        mutable.remove(value)
        self.balances = mutable.copy() as! NSSet
    }

}

extension _CD_MembershipPlan {

    open func addImages(_ objects: NSSet) {
        let mutable = self.images.mutableCopy() as! NSMutableSet
        mutable.union(objects as Set<NSObject>)
        self.images = mutable.copy() as! NSSet
    }

    open func removeImages(_ objects: NSSet) {
        let mutable = self.images.mutableCopy() as! NSMutableSet
        mutable.minus(objects as Set<NSObject>)
        self.images = mutable.copy() as! NSSet
    }

    open func addImagesObject(_ value: CD_MembershipPlanImage) {
        let mutable = self.images.mutableCopy() as! NSMutableSet
        mutable.add(value)
        self.images = mutable.copy() as! NSSet
    }

    open func removeImagesObject(_ value: CD_MembershipPlanImage) {
        let mutable = self.images.mutableCopy() as! NSMutableSet
        mutable.remove(value)
        self.images = mutable.copy() as! NSSet
    }

}

extension _CD_MembershipPlan {

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

