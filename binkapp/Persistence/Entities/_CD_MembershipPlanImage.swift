// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CD_MembershipPlanImage.swift instead.

// swiftlint:disable all

import Foundation
import CoreData

public enum CD_MembershipPlanImageAttributes: String {
    case encoding = "encoding"
    case imageDescription = "imageDescription"
    case type = "type"
    case url = "url"
}

public enum CD_MembershipPlanImageRelationships: String {
    case plan = "plan"
}

open class _CD_MembershipPlanImage: CD_BaseObject {

    // MARK: - Class methods

    override open class func entityName () -> String {
        return "CD_MembershipPlanImage"
    }

    override open class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    @nonobjc
    open class func fetchRequest() -> NSFetchRequest<CD_MembershipPlanImage> {
        return NSFetchRequest(entityName: self.entityName())
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _CD_MembershipPlanImage.entity(managedObjectContext: managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var encoding: String?

    @NSManaged open
    var imageDescription: String?

    @NSManaged open
    var type: NSNumber?

    @NSManaged open
    var url: String?

    // MARK: - Relationships

    @NSManaged open
    var plan: CD_MembershipPlan?

}

