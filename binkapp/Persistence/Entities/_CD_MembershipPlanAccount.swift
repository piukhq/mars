// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CD_MembershipPlanAccount.swift instead.

// swiftlint:disable all

import Foundation
import CoreData

public enum CD_MembershipPlanAccountAttributes: String {
    case barcodeRedeemInstructions = "barcodeRedeemInstructions"
    case category = "category"
    case companyName = "companyName"
    case companyURL = "companyURL"
    case enrolIncentive = "enrolIncentive"
    case forgottenPasswordUrl = "forgottenPasswordUrl"
    case planDescription = "planDescription"
    case planName = "planName"
    case planNameCard = "planNameCard"
    case planRegisterInfo = "planRegisterInfo"
    case planSummary = "planSummary"
    case planURL = "planURL"
}

public enum CD_MembershipPlanAccountRelationships: String {
    case addFields = "addFields"
    case authoriseFields = "authoriseFields"
    case enrolFields = "enrolFields"
    case plan = "plan"
    case planDocuments = "planDocuments"
    case registrationFields = "registrationFields"
    case tiers = "tiers"
}

open class _CD_MembershipPlanAccount: CD_BaseObject {

    // MARK: - Class methods

    override open class func entityName () -> String {
        return "CD_MembershipPlanAccount"
    }

    override open class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    @nonobjc
    open class func fetchRequest() -> NSFetchRequest<CD_MembershipPlanAccount> {
        return NSFetchRequest(entityName: self.entityName())
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _CD_MembershipPlanAccount.entity(managedObjectContext: managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var barcodeRedeemInstructions: String?

    @NSManaged open
    var category: String?

    @NSManaged open
    var companyName: String?

    @NSManaged open
    var companyURL: String?

    @NSManaged open
    var enrolIncentive: String?

    @NSManaged open
    var forgottenPasswordUrl: String?

    @NSManaged open
    var planDescription: String?

    @NSManaged open
    var planName: String?

    @NSManaged open
    var planNameCard: String?

    @NSManaged open
    var planRegisterInfo: String?

    @NSManaged open
    var planSummary: String?

    @NSManaged open
    var planURL: String?

    // MARK: - Relationships

    @NSManaged open
    var addFields: NSSet

    open func addFieldsSet() -> NSMutableSet {
        return self.addFields.mutableCopy() as! NSMutableSet
    }

    @NSManaged open
    var authoriseFields: NSSet

    open func authoriseFieldsSet() -> NSMutableSet {
        return self.authoriseFields.mutableCopy() as! NSMutableSet
    }

    @NSManaged open
    var enrolFields: NSSet

    open func enrolFieldsSet() -> NSMutableSet {
        return self.enrolFields.mutableCopy() as! NSMutableSet
    }

    @NSManaged open
    var plan: CD_MembershipPlan?

    @NSManaged open
    var planDocuments: NSSet

    open func planDocumentsSet() -> NSMutableSet {
        return self.planDocuments.mutableCopy() as! NSMutableSet
    }

    @NSManaged open
    var registrationFields: NSSet

    open func registrationFieldsSet() -> NSMutableSet {
        return self.registrationFields.mutableCopy() as! NSMutableSet
    }

    @NSManaged open
    var tiers: NSSet

    open func tiersSet() -> NSMutableSet {
        return self.tiers.mutableCopy() as! NSMutableSet
    }

}

extension _CD_MembershipPlanAccount {

    open func addAddFields(_ objects: NSSet) {
        let mutable = self.addFields.mutableCopy() as! NSMutableSet
        mutable.union(objects as Set<NSObject>)
        self.addFields = mutable.copy() as! NSSet
    }

    open func removeAddFields(_ objects: NSSet) {
        let mutable = self.addFields.mutableCopy() as! NSMutableSet
        mutable.minus(objects as Set<NSObject>)
        self.addFields = mutable.copy() as! NSSet
    }

    open func addAddFieldsObject(_ value: CD_AddField) {
        let mutable = self.addFields.mutableCopy() as! NSMutableSet
        mutable.add(value)
        self.addFields = mutable.copy() as! NSSet
    }

    open func removeAddFieldsObject(_ value: CD_AddField) {
        let mutable = self.addFields.mutableCopy() as! NSMutableSet
        mutable.remove(value)
        self.addFields = mutable.copy() as! NSSet
    }

}

extension _CD_MembershipPlanAccount {

    open func addAuthoriseFields(_ objects: NSSet) {
        let mutable = self.authoriseFields.mutableCopy() as! NSMutableSet
        mutable.union(objects as Set<NSObject>)
        self.authoriseFields = mutable.copy() as! NSSet
    }

    open func removeAuthoriseFields(_ objects: NSSet) {
        let mutable = self.authoriseFields.mutableCopy() as! NSMutableSet
        mutable.minus(objects as Set<NSObject>)
        self.authoriseFields = mutable.copy() as! NSSet
    }

    open func addAuthoriseFieldsObject(_ value: CD_AuthoriseField) {
        let mutable = self.authoriseFields.mutableCopy() as! NSMutableSet
        mutable.add(value)
        self.authoriseFields = mutable.copy() as! NSSet
    }

    open func removeAuthoriseFieldsObject(_ value: CD_AuthoriseField) {
        let mutable = self.authoriseFields.mutableCopy() as! NSMutableSet
        mutable.remove(value)
        self.authoriseFields = mutable.copy() as! NSSet
    }

}

extension _CD_MembershipPlanAccount {

    open func addEnrolFields(_ objects: NSSet) {
        let mutable = self.enrolFields.mutableCopy() as! NSMutableSet
        mutable.union(objects as Set<NSObject>)
        self.enrolFields = mutable.copy() as! NSSet
    }

    open func removeEnrolFields(_ objects: NSSet) {
        let mutable = self.enrolFields.mutableCopy() as! NSMutableSet
        mutable.minus(objects as Set<NSObject>)
        self.enrolFields = mutable.copy() as! NSSet
    }

    open func addEnrolFieldsObject(_ value: CD_EnrolField) {
        let mutable = self.enrolFields.mutableCopy() as! NSMutableSet
        mutable.add(value)
        self.enrolFields = mutable.copy() as! NSSet
    }

    open func removeEnrolFieldsObject(_ value: CD_EnrolField) {
        let mutable = self.enrolFields.mutableCopy() as! NSMutableSet
        mutable.remove(value)
        self.enrolFields = mutable.copy() as! NSSet
    }

}

extension _CD_MembershipPlanAccount {

    open func addPlanDocuments(_ objects: NSSet) {
        let mutable = self.planDocuments.mutableCopy() as! NSMutableSet
        mutable.union(objects as Set<NSObject>)
        self.planDocuments = mutable.copy() as! NSSet
    }

    open func removePlanDocuments(_ objects: NSSet) {
        let mutable = self.planDocuments.mutableCopy() as! NSMutableSet
        mutable.minus(objects as Set<NSObject>)
        self.planDocuments = mutable.copy() as! NSSet
    }

    open func addPlanDocumentsObject(_ value: CD_PlanDocument) {
        let mutable = self.planDocuments.mutableCopy() as! NSMutableSet
        mutable.add(value)
        self.planDocuments = mutable.copy() as! NSSet
    }

    open func removePlanDocumentsObject(_ value: CD_PlanDocument) {
        let mutable = self.planDocuments.mutableCopy() as! NSMutableSet
        mutable.remove(value)
        self.planDocuments = mutable.copy() as! NSSet
    }

}

extension _CD_MembershipPlanAccount {

    open func addRegistrationFields(_ objects: NSSet) {
        let mutable = self.registrationFields.mutableCopy() as! NSMutableSet
        mutable.union(objects as Set<NSObject>)
        self.registrationFields = mutable.copy() as! NSSet
    }

    open func removeRegistrationFields(_ objects: NSSet) {
        let mutable = self.registrationFields.mutableCopy() as! NSMutableSet
        mutable.minus(objects as Set<NSObject>)
        self.registrationFields = mutable.copy() as! NSSet
    }

    open func addRegistrationFieldsObject(_ value: CD_RegistrationField) {
        let mutable = self.registrationFields.mutableCopy() as! NSMutableSet
        mutable.add(value)
        self.registrationFields = mutable.copy() as! NSSet
    }

    open func removeRegistrationFieldsObject(_ value: CD_RegistrationField) {
        let mutable = self.registrationFields.mutableCopy() as! NSMutableSet
        mutable.remove(value)
        self.registrationFields = mutable.copy() as! NSSet
    }

}

extension _CD_MembershipPlanAccount {

    open func addTiers(_ objects: NSSet) {
        let mutable = self.tiers.mutableCopy() as! NSMutableSet
        mutable.union(objects as Set<NSObject>)
        self.tiers = mutable.copy() as! NSSet
    }

    open func removeTiers(_ objects: NSSet) {
        let mutable = self.tiers.mutableCopy() as! NSMutableSet
        mutable.minus(objects as Set<NSObject>)
        self.tiers = mutable.copy() as! NSSet
    }

    open func addTiersObject(_ value: CD_Tier) {
        let mutable = self.tiers.mutableCopy() as! NSMutableSet
        mutable.add(value)
        self.tiers = mutable.copy() as! NSSet
    }

    open func removeTiersObject(_ value: CD_Tier) {
        let mutable = self.tiers.mutableCopy() as! NSMutableSet
        mutable.remove(value)
        self.tiers = mutable.copy() as! NSSet
    }

}

