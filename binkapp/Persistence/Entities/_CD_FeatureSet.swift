// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CD_FeatureSet.swift instead.

import Foundation
import CoreData

public enum CD_FeatureSetAttributes: String {
    case authorisationRequired = "authorisationRequired"
    case cardType = "cardType"
    case digitalOnly = "digitalOnly"
    case hasPoints = "hasPoints"
    case id = "id"
    case transactionsAvailable = "transactionsAvailable"
}

public enum CD_FeatureSetRelationships: String {
    case plan = "plan"
}

open class _CD_FeatureSet: NSManagedObject {

    // MARK: - Class methods

    open class func entityName () -> String {
        return "CD_FeatureSet"
    }

    open class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    @nonobjc
    open class func fetchRequest() -> NSFetchRequest<CD_FeatureSet> {
        return NSFetchRequest(entityName: self.entityName())
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _CD_FeatureSet.entity(managedObjectContext: managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var authorisationRequired: NSNumber?

    @NSManaged open
    var cardType: NSNumber?

    @NSManaged open
    var digitalOnly: NSNumber?

    @NSManaged open
    var hasPoints: NSNumber?

    @NSManaged open
    var id: String!

    @NSManaged open
    var transactionsAvailable: NSNumber?

    // MARK: - Relationships

    @NSManaged open
    var plan: CD_MembershipPlan?

}

