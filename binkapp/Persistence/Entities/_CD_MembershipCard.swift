// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CD_MembershipCard.swift instead.

import Foundation
import CoreData

public enum CD_MembershipCardRelationships: String {
    case account = "account"
    case balances = "balances"
    case card = "card"
    case images = "images"
    case linkedPaymentCards = "linkedPaymentCards"
    case membershipPlan = "membershipPlan"
    case status = "status"
    case transactions = "transactions"
    case vouchers = "vouchers"
}

open class _CD_MembershipCard: CD_CardAccount {

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
    var linkedPaymentCards: NSSet

    open func linkedPaymentCardsSet() -> NSMutableSet {
        return self.linkedPaymentCards.mutableCopy() as! NSMutableSet
    }

    @NSManaged open
    var membershipPlan: CD_MembershipPlan?

    @NSManaged open
    var status: CD_MembershipCardStatus?

    @NSManaged open
    var transactions: NSSet

    open func transactionsSet() -> NSMutableSet {
        return self.transactions.mutableCopy() as! NSMutableSet
    }

    @NSManaged open
    var vouchers: NSSet

    open func vouchersSet() -> NSMutableSet {
        return self.vouchers.mutableCopy() as! NSMutableSet
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

    open func addLinkedPaymentCards(_ objects: NSSet) {
        let mutable = self.linkedPaymentCards.mutableCopy() as! NSMutableSet
        mutable.union(objects as Set<NSObject>)
        self.linkedPaymentCards = mutable.copy() as! NSSet
    }

    open func removeLinkedPaymentCards(_ objects: NSSet) {
        let mutable = self.linkedPaymentCards.mutableCopy() as! NSMutableSet
        mutable.minus(objects as Set<NSObject>)
        self.linkedPaymentCards = mutable.copy() as! NSSet
    }

    open func addLinkedPaymentCardsObject(_ value: CD_PaymentCard) {
        let mutable = self.linkedPaymentCards.mutableCopy() as! NSMutableSet
        mutable.add(value)
        self.linkedPaymentCards = mutable.copy() as! NSSet
    }

    open func removeLinkedPaymentCardsObject(_ value: CD_PaymentCard) {
        let mutable = self.linkedPaymentCards.mutableCopy() as! NSMutableSet
        mutable.remove(value)
        self.linkedPaymentCards = mutable.copy() as! NSSet
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

extension _CD_MembershipCard {

    open func addVouchers(_ objects: NSSet) {
        let mutable = self.vouchers.mutableCopy() as! NSMutableSet
        mutable.union(objects as Set<NSObject>)
        self.vouchers = mutable.copy() as! NSSet
    }

    open func removeVouchers(_ objects: NSSet) {
        let mutable = self.vouchers.mutableCopy() as! NSMutableSet
        mutable.minus(objects as Set<NSObject>)
        self.vouchers = mutable.copy() as! NSSet
    }

    open func addVouchersObject(_ value: CD_Voucher) {
        let mutable = self.vouchers.mutableCopy() as! NSMutableSet
        mutable.add(value)
        self.vouchers = mutable.copy() as! NSSet
    }

    open func removeVouchersObject(_ value: CD_Voucher) {
        let mutable = self.vouchers.mutableCopy() as! NSMutableSet
        mutable.remove(value)
        self.vouchers = mutable.copy() as! NSSet
    }

}

