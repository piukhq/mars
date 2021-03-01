// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CD_BaseImage.swift instead.

import Foundation
import CoreData

public enum CD_BaseImageAttributes: String {
    case darkModeImageUrl = "darkModeImageUrl"
    case imageUrl = "imageUrl"
}

open class _CD_BaseImage: CD_BaseObject {

    // MARK: - Class methods

    override open class func entityName () -> String {
        return "CD_BaseImage"
    }

    override open class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    @nonobjc
    open class func fetchRequest() -> NSFetchRequest<CD_BaseImage> {
        return NSFetchRequest(entityName: self.entityName())
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _CD_BaseImage.entity(managedObjectContext: managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var darkModeImageUrl: String?

    @NSManaged open
    var imageUrl: String?

    // MARK: - Relationships

}

