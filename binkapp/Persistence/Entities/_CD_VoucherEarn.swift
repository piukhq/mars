// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CD_VoucherEarn.swift instead.

import Foundation
import CoreData

public enum CD_VoucherEarnAttributes: String {
    case currency = "currency"
    case prefix = "prefix"
    case suffix = "suffix"
    case targetValue = "targetValue"
    case type = "type"
    case value = "value"
}

public enum CD_VoucherEarnRelationships: String {
    case voucher = "voucher"
}

open class _CD_VoucherEarn: CD_BaseObject {

    // MARK: - Class methods

    override open class func entityName () -> String {
        return "CD_VoucherEarn"
    }

    override open class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    @nonobjc
    open class func fetchRequest() -> NSFetchRequest<CD_VoucherEarn> {
        return NSFetchRequest(entityName: self.entityName())
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _CD_VoucherEarn.entity(managedObjectContext: managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var currency: String?

    @NSManaged open
    var prefix: String?

    @NSManaged open
    var suffix: String?

    @NSManaged open
    var targetValue: NSNumber?

    @NSManaged open
    var type: String?

    @NSManaged open
    var value: NSNumber?

    // MARK: - Relationships

    @NSManaged open
    var voucher: CD_Voucher?

}

