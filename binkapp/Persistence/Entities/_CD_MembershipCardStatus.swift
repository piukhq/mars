// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CD_MembershipCardStatus.swift instead.

import Foundation
import CoreData

public enum CD_MembershipCardStatusAttributes: String {
    case state = "state"
}

public enum CD_MembershipCardStatusRelationships: String {
    case card = "card"
    case reasonCodes = "reasonCodes"
}

open class _CD_MembershipCardStatus: CD_BaseObject {

    // MARK: - Class methods

    override open class func entityName () -> String {
        return "CD_MembershipCardStatus"
    }

    override open class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    @nonobjc
    open class func fetchRequest() -> NSFetchRequest<CD_MembershipCardStatus> {
        return NSFetchRequest(entityName: self.entityName())
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _CD_MembershipCardStatus.entity(managedObjectContext: managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var state: String?

    // MARK: - Relationships

    @NSManaged open
    var card: CD_MembershipCard?

    @NSManaged open
    var reasonCodes: NSSet

    open func reasonCodesSet() -> NSMutableSet {
        return self.reasonCodes.mutableCopy() as! NSMutableSet
    }

}

extension _CD_MembershipCardStatus {

    open func addReasonCodes(_ objects: NSSet) {
        let mutable = self.reasonCodes.mutableCopy() as! NSMutableSet
        mutable.union(objects as Set<NSObject>)
        self.reasonCodes = mutable.copy() as! NSSet
    }

    open func removeReasonCodes(_ objects: NSSet) {
        let mutable = self.reasonCodes.mutableCopy() as! NSMutableSet
        mutable.minus(objects as Set<NSObject>)
        self.reasonCodes = mutable.copy() as! NSSet
    }

    open func addReasonCodesObject(_ value: CD_ReasonCode) {
        let mutable = self.reasonCodes.mutableCopy() as! NSMutableSet
        mutable.add(value)
        self.reasonCodes = mutable.copy() as! NSSet
    }

    open func removeReasonCodesObject(_ value: CD_ReasonCode) {
        let mutable = self.reasonCodes.mutableCopy() as! NSMutableSet
        mutable.remove(value)
        self.reasonCodes = mutable.copy() as! NSSet
    }

}

