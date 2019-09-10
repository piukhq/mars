// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CD_App.swift instead.

import Foundation
import CoreData

public enum CD_AppAttributes: String {
    case appId = "appId"
    case appStoreUrl = "appStoreUrl"
    case appType = "appType"
    case id = "id"
}

open class _CD_App: NSManagedObject {

    // MARK: - Class methods

    open class func entityName () -> String {
        return "CD_App"
    }

    open class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    @nonobjc
    open class func fetchRequest() -> NSFetchRequest<CD_App> {
        return NSFetchRequest(entityName: self.entityName())
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _CD_App.entity(managedObjectContext: managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var appId: String?

    @NSManaged open
    var appStoreUrl: String?

    @NSManaged open
    var appType: NSNumber?

    @NSManaged open
    var id: String!

    // MARK: - Relationships

}

