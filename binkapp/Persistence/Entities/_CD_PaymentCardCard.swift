// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CD_PaymentCardCard.swift instead.

import Foundation
import CoreData

public enum CD_PaymentCardCardAttributes: String {
    case country = "country"
    case currencyCode = "currencyCode"
    case firstSix = "firstSix"
    case lastFour = "lastFour"
    case month = "month"
    case nameOnCard = "nameOnCard"
    case provider = "provider"
    case type = "type"
    case year = "year"
}

public enum CD_PaymentCardCardRelationships: String {
    case paymentCard = "paymentCard"
}

open class _CD_PaymentCardCard: CD_BaseObject {

    // MARK: - Class methods

    override open class func entityName () -> String {
        return "CD_PaymentCardCard"
    }

    override open class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    @nonobjc
    open class func fetchRequest() -> NSFetchRequest<CD_PaymentCardCard> {
        return NSFetchRequest(entityName: self.entityName())
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _CD_PaymentCardCard.entity(managedObjectContext: managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var country: String?

    @NSManaged open
    var currencyCode: String?

    @NSManaged open
    var firstSix: String?

    @NSManaged open
    var lastFour: String?

    @NSManaged open
    var month: NSNumber?

    @NSManaged open
    var nameOnCard: String?

    @NSManaged open
    var provider: String?

    @NSManaged open
    var type: String?

    @NSManaged open
    var year: NSNumber?

    // MARK: - Relationships

    @NSManaged open
    var paymentCard: CD_PaymentCard?

}

