// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CD_PlanDocument.swift instead.

import Foundation
import CoreData

public enum CD_PlanDocumentAttributes: String {
    case checkbox = "checkbox"
    case documentDescription = "documentDescription"
    case name = "name"
    case url = "url"
}

public enum CD_PlanDocumentRelationships: String {
    case display = "display"
    case planAccount = "planAccount"
}

open class _CD_PlanDocument: CD_BaseObject {

    // MARK: - Class methods

    override open class func entityName () -> String {
        return "CD_PlanDocument"
    }

    override open class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    @nonobjc
    open class func fetchRequest() -> NSFetchRequest<CD_PlanDocument> {
        return NSFetchRequest(entityName: self.entityName())
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _CD_PlanDocument.entity(managedObjectContext: managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var checkbox: NSNumber?

    @NSManaged open
    var documentDescription: String?

    @NSManaged open
    var name: String?

    @NSManaged open
    var url: String?

    // MARK: - Relationships

    @NSManaged open
    var display: CD_PlanDocumentDisplay?

    @NSManaged open
    var planAccount: CD_MembershipPlanAccount?

}

