// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CD_Card.swift instead.

import Foundation
import CoreData

public enum CD_CardAttributes: String {
    case barcode = "barcode"
    case barcodeType = "barcodeType"
    case colour = "colour"
    case id = "id"
    case membershipId = "membershipId"
}

public enum CD_CardRelationships: String {
    case membershipCard = "membershipCard"
}

open class _CD_Card: NSManagedObject {

    // MARK: - Class methods

    open class func entityName () -> String {
        return "CD_Card"
    }

    open class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    @nonobjc
    open class func fetchRequest() -> NSFetchRequest<CD_Card> {
        return NSFetchRequest(entityName: self.entityName())
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _CD_Card.entity(managedObjectContext: managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var barcode: String?

    @NSManaged open
    var barcodeType: NSNumber?

    @NSManaged open
    var colour: String?

    @NSManaged open
    var id: String!

    @NSManaged open
    var membershipId: String?

    // MARK: - Relationships

    @NSManaged open
    var membershipCard: CD_MembershipCard?

}

