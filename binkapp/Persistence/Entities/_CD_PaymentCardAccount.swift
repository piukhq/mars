// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CD_PaymentCardAccount.swift instead.

import Foundation
import CoreData

public enum CD_PaymentCardAccountAttributes: String {
    case status = "status"
    case verificationInProgress = "verificationInProgress"
}

public enum CD_PaymentCardAccountRelationships: String {
    case consents = "consents"
    case paymentCard = "paymentCard"
}

open class _CD_PaymentCardAccount: CD_BaseObject {

    // MARK: - Class methods

    override open class func entityName () -> String {
        return "CD_PaymentCardAccount"
    }

    override open class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    @nonobjc
    open class func fetchRequest() -> NSFetchRequest<CD_PaymentCardAccount> {
        return NSFetchRequest(entityName: self.entityName())
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _CD_PaymentCardAccount.entity(managedObjectContext: managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var status: NSNumber?

    @NSManaged open
    var verificationInProgress: NSNumber?

    // MARK: - Relationships

    @NSManaged open
    var consents: NSSet

    open func consentsSet() -> NSMutableSet {
        return self.consents.mutableCopy() as! NSMutableSet
    }

    @NSManaged open
    var paymentCard: CD_PaymentCard?

}

extension _CD_PaymentCardAccount {

    open func addConsents(_ objects: NSSet) {
        let mutable = self.consents.mutableCopy() as! NSMutableSet
        mutable.union(objects as Set<NSObject>)
        self.consents = mutable.copy() as! NSSet
    }

    open func removeConsents(_ objects: NSSet) {
        let mutable = self.consents.mutableCopy() as! NSMutableSet
        mutable.minus(objects as Set<NSObject>)
        self.consents = mutable.copy() as! NSSet
    }

    open func addConsentsObject(_ value: CD_PaymentCardAccountConsents) {
        let mutable = self.consents.mutableCopy() as! NSMutableSet
        mutable.add(value)
        self.consents = mutable.copy() as! NSSet
    }

    open func removeConsentsObject(_ value: CD_PaymentCardAccountConsents) {
        let mutable = self.consents.mutableCopy() as! NSMutableSet
        mutable.remove(value)
        self.consents = mutable.copy() as! NSSet
    }

}

