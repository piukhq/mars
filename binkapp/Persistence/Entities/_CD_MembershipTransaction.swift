// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CD_MembershipTransaction.swift instead.

import Foundation
import CoreData

public enum CD_MembershipTransactionAttributes: String {
    case status = "status"
    case timestamp = "timestamp"
    case transactionDescription = "transactionDescription"
}

public enum CD_MembershipTransactionRelationships: String {
    case amounts = "amounts"
    case card = "card"
}

open class _CD_MembershipTransaction: CD_BaseObject {

    // MARK: - Class methods

    override open class func entityName () -> String {
        return "CD_MembershipTransaction"
    }

    override open class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    @nonobjc
    open class func fetchRequest() -> NSFetchRequest<CD_MembershipTransaction> {
        return NSFetchRequest(entityName: self.entityName())
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _CD_MembershipTransaction.entity(managedObjectContext: managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var status: String?

    @NSManaged open
    var timestamp: NSNumber?

    @NSManaged open
    var transactionDescription: String?

    // MARK: - Relationships

    @NSManaged open
    var amounts: NSSet

    open func amountsSet() -> NSMutableSet {
        return self.amounts.mutableCopy() as! NSMutableSet
    }

    @NSManaged open
    var card: CD_MembershipCard?

}

extension _CD_MembershipTransaction {

    open func addAmounts(_ objects: NSSet) {
        let mutable = self.amounts.mutableCopy() as! NSMutableSet
        mutable.union(objects as Set<NSObject>)
        self.amounts = mutable.copy() as! NSSet
    }

    open func removeAmounts(_ objects: NSSet) {
        let mutable = self.amounts.mutableCopy() as! NSMutableSet
        mutable.minus(objects as Set<NSObject>)
        self.amounts = mutable.copy() as! NSSet
    }

    open func addAmountsObject(_ value: CD_MembershipCardAmount) {
        let mutable = self.amounts.mutableCopy() as! NSMutableSet
        mutable.add(value)
        self.amounts = mutable.copy() as! NSSet
    }

    open func removeAmountsObject(_ value: CD_MembershipCardAmount) {
        let mutable = self.amounts.mutableCopy() as! NSMutableSet
        mutable.remove(value)
        self.amounts = mutable.copy() as! NSSet
    }

}

