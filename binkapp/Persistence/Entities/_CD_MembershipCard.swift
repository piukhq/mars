// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CD_MembershipCard.swift instead.

import Foundation
import CoreData

public enum CD_MembershipCardRelationships: String {
    case account = "account"
    case balances = "balances"
    case card = "card"
    case images = "images"
    case membershipPlan = "membershipPlan"
    case paymentCards = "paymentCards"
    case status = "status"
    case transactions = "transactions"
}

open class _CD_MembershipCard: CD_BaseObject {

    // MARK: - Class methods

    override open class func entityName () -> String {
        return "CD_MembershipCard"
    }

    override open class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    @nonobjc
    open class func fetchRequest() -> NSFetchRequest<CD_MembershipCard> {
        return NSFetchRequest(entityName: self.entityName())
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _CD_MembershipCard.entity(managedObjectContext: managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    // MARK: - Relationships

    @NSManaged open
    var account: CD_MembershipCardAccount?

    @NSManaged open
    var balances: NSSet

    open func balancesSet() -> NSMutableSet {
        return self.balances.mutableCopy() as! NSMutableSet
    }

    @NSManaged open
    var card: CD_Card?

    @NSManaged open
    var images: NSSet

    open func imagesSet() -> NSMutableSet {
        return self.images.mutableCopy() as! NSMutableSet
    }

    @NSManaged open
    var membershipPlan: CD_MembershipPlan?

    @NSManaged open
    var paymentCards: NSSet

    open func paymentCardsSet() -> NSMutableSet {
        return self.paymentCards.mutableCopy() as! NSMutableSet
    }

    @NSManaged open
    var status: CD_MembershipCardStatus?

    @NSManaged open
    var transactions: NSSet

    open func transactionsSet() -> NSMutableSet {
        return self.transactions.mutableCopy() as! NSMutableSet
    }

}

extension _CD_MembershipCard {

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

    open func addBalancesObject(_ value: CD_MembershipCardBalance) {
        let mutable = self.balances.mutableCopy() as! NSMutableSet
        mutable.add(value)
        self.balances = mutable.copy() as! NSSet
    }

    open func removeBalancesObject(_ value: CD_MembershipCardBalance) {
        let mutable = self.balances.mutableCopy() as! NSMutableSet
        mutable.remove(value)
        self.balances = mutable.copy() as! NSSet
    }

}

extension _CD_MembershipCard {

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

    open func addImagesObject(_ value: CD_MembershipCardImage) {
        let mutable = self.images.mutableCopy() as! NSMutableSet
        mutable.add(value)
        self.images = mutable.copy() as! NSSet
    }

    open func removeImagesObject(_ value: CD_MembershipCardImage) {
        let mutable = self.images.mutableCopy() as! NSMutableSet
        mutable.remove(value)
        self.images = mutable.copy() as! NSSet
    }

}

extension _CD_MembershipCard {

    open func addPaymentCards(_ objects: NSSet) {
        let mutable = self.paymentCards.mutableCopy() as! NSMutableSet
        mutable.union(objects as Set<NSObject>)
        self.paymentCards = mutable.copy() as! NSSet
    }

    open func removePaymentCards(_ objects: NSSet) {
        let mutable = self.paymentCards.mutableCopy() as! NSMutableSet
        mutable.minus(objects as Set<NSObject>)
        self.paymentCards = mutable.copy() as! NSSet
    }

    open func addPaymentCardsObject(_ value: CD_PaymentCard) {
        let mutable = self.paymentCards.mutableCopy() as! NSMutableSet
        mutable.add(value)
        self.paymentCards = mutable.copy() as! NSSet
    }

    open func removePaymentCardsObject(_ value: CD_PaymentCard) {
        let mutable = self.paymentCards.mutableCopy() as! NSMutableSet
        mutable.remove(value)
        self.paymentCards = mutable.copy() as! NSSet
    }

}

extension _CD_MembershipCard {

    open func addTransactions(_ objects: NSSet) {
        let mutable = self.transactions.mutableCopy() as! NSMutableSet
        mutable.union(objects as Set<NSObject>)
        self.transactions = mutable.copy() as! NSSet
    }

    open func removeTransactions(_ objects: NSSet) {
        let mutable = self.transactions.mutableCopy() as! NSMutableSet
        mutable.minus(objects as Set<NSObject>)
        self.transactions = mutable.copy() as! NSSet
    }

    open func addTransactionsObject(_ value: CD_MembershipTransaction) {
        let mutable = self.transactions.mutableCopy() as! NSMutableSet
        mutable.add(value)
        self.transactions = mutable.copy() as! NSSet
    }

    open func removeTransactionsObject(_ value: CD_MembershipTransaction) {
        let mutable = self.transactions.mutableCopy() as! NSMutableSet
        mutable.remove(value)
        self.transactions = mutable.copy() as! NSSet
    }

}

