// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CD_FeatureSet.swift instead.

// swiftlint:disable all

import Foundation
import CoreData

public enum CD_FeatureSetAttributes: String {
    case authorisationRequired = "authorisationRequired"
    case cardType = "cardType"
    case digitalOnly = "digitalOnly"
    case hasPoints = "hasPoints"
    case hasVouchers = "hasVouchers"
    case transactionsAvailable = "transactionsAvailable"
}

public enum CD_FeatureSetRelationships: String {
    case linkingSupport = "linkingSupport"
    case plan = "plan"
}

open class _CD_FeatureSet: CD_BaseObject {

    // MARK: - Class methods

    override open class func entityName () -> String {
        return "CD_FeatureSet"
    }

    override open class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    @nonobjc
    open class func fetchRequest() -> NSFetchRequest<CD_FeatureSet> {
        return NSFetchRequest(entityName: self.entityName())
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _CD_FeatureSet.entity(managedObjectContext: managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var authorisationRequired: NSNumber?

    @NSManaged open
    var cardType: NSNumber?

    @NSManaged open
    var digitalOnly: NSNumber?

    @NSManaged open
    var hasPoints: NSNumber?

    @NSManaged open
    var hasVouchers: NSNumber?

    @NSManaged open
    var transactionsAvailable: NSNumber?

    // MARK: - Relationships

    @NSManaged open
    var linkingSupport: NSSet

    open func linkingSupportSet() -> NSMutableSet {
        return self.linkingSupport.mutableCopy() as! NSMutableSet
    }

    @NSManaged open
    var plan: CD_MembershipPlan?

}

extension _CD_FeatureSet {

    open func addLinkingSupport(_ objects: NSSet) {
        let mutable = self.linkingSupport.mutableCopy() as! NSMutableSet
        mutable.union(objects as Set<NSObject>)
        self.linkingSupport = mutable.copy() as! NSSet
    }

    open func removeLinkingSupport(_ objects: NSSet) {
        let mutable = self.linkingSupport.mutableCopy() as! NSMutableSet
        mutable.minus(objects as Set<NSObject>)
        self.linkingSupport = mutable.copy() as! NSSet
    }

    open func addLinkingSupportObject(_ value: CD_LinkingSupport) {
        let mutable = self.linkingSupport.mutableCopy() as! NSMutableSet
        mutable.add(value)
        self.linkingSupport = mutable.copy() as! NSSet
    }

    open func removeLinkingSupportObject(_ value: CD_LinkingSupport) {
        let mutable = self.linkingSupport.mutableCopy() as! NSMutableSet
        mutable.remove(value)
        self.linkingSupport = mutable.copy() as! NSSet
    }

}

