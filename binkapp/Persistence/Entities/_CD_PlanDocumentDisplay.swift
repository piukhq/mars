// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CD_PlanDocumentDisplay.swift instead.
// swiftlint:disable all


import Foundation
import CoreData

public enum CD_PlanDocumentDisplayAttributes: String {
    case value = "value"
}

public enum CD_PlanDocumentDisplayRelationships: String {
    case planDocument = "planDocument"
}

open class _CD_PlanDocumentDisplay: CD_BaseObject {

    // MARK: - Class methods

    override open class func entityName () -> String {
        return "CD_PlanDocumentDisplay"
    }

    override open class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    @nonobjc
    open class func fetchRequest() -> NSFetchRequest<CD_PlanDocumentDisplay> {
        return NSFetchRequest(entityName: self.entityName())
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _CD_PlanDocumentDisplay.entity(managedObjectContext: managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var value: String?

    // MARK: - Relationships

    @NSManaged open
    var planDocument: CD_PlanDocument?

}

