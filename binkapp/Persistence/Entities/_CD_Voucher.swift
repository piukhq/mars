// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CD_Voucher.swift instead.

import Foundation
import CoreData

public enum CD_VoucherAttributes: String {
    case barcode = "barcode"
    case barcodeType = "barcodeType"
    case code = "code"
    case dateIssued = "dateIssued"
    case dateRedeemed = "dateRedeemed"
    case expiryDate = "expiryDate"
    case headline = "headline"
    case state = "state"
    case subtext = "subtext"
}

public enum CD_VoucherRelationships: String {
    case burn = "burn"
    case earn = "earn"
    case membershipCard = "membershipCard"
}

open class _CD_Voucher: CD_BaseObject {

    // MARK: - Class methods

    override open class func entityName () -> String {
        return "CD_Voucher"
    }

    override open class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    @nonobjc
    open class func fetchRequest() -> NSFetchRequest<CD_Voucher> {
        return NSFetchRequest(entityName: self.entityName())
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _CD_Voucher.entity(managedObjectContext: managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var barcode: String?

    @NSManaged open
    var barcodeType: String?

    @NSManaged open
    var code: String?

    @NSManaged open
    var dateIssued: NSNumber?

    @NSManaged open
    var dateRedeemed: NSNumber?

    @NSManaged open
    var expiryDate: NSNumber?

    @NSManaged open
    var headline: String?

    @NSManaged open
    var state: String?

    @NSManaged open
    var subtext: String?

    // MARK: - Relationships

    @NSManaged open
    var burn: CD_VoucherBurn?

    @NSManaged open
    var earn: CD_VoucherEarn?

    @NSManaged open
    var membershipCard: CD_MembershipCard?

}

