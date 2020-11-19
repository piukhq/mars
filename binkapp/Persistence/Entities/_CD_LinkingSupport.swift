// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CD_LinkingSupport.swift instead.

// swiftlint:disable all

import Foundation
import CoreData

public enum CD_LinkingSupportAttributes: String {
    case value = "value"
}

public enum CD_LinkingSupportRelationships: String {
    case featureSet = "featureSet"
}

open class _CD_LinkingSupport: CD_BaseObject {

    // MARK: - Class methods

    override open class func entityName () -> String {
        return "CD_LinkingSupport"
    }

    override open class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    @nonobjc
    open class func fetchRequest() -> NSFetchRequest<CD_LinkingSupport> {
        return NSFetchRequest(entityName: self.entityName())
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _CD_LinkingSupport.entity(managedObjectContext: managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var value: String?

    // MARK: - Relationships

    @NSManaged open
    var featureSet: CD_FeatureSet?

}

