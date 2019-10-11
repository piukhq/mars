// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CD_AddField.swift instead.

import Foundation
import CoreData

public enum CD_AddFieldAttributes: String {
    case column = "column"
    case fieldDescription = "fieldDescription"
    case order = "order"
    case type = "type"
    case validation = "validation"
}

public enum CD_AddFieldRelationships: String {
    case choices = "choices"
    case planAccount = "planAccount"
}

open class _CD_AddField: CD_BaseObject {

    // MARK: - Class methods

    override open class func entityName () -> String {
        return "CD_AddField"
    }

    override open class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    @nonobjc
    open class func fetchRequest() -> NSFetchRequest<CD_AddField> {
        return NSFetchRequest(entityName: self.entityName())
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _CD_AddField.entity(managedObjectContext: managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var column: String?

    @NSManaged open
    var fieldDescription: String?

    @NSManaged open
    var order: NSNumber!

    @NSManaged open
    var type: NSNumber?

    @NSManaged open
    var validation: String?

    // MARK: - Relationships

    @NSManaged open
    var choices: NSSet

    open func choicesSet() -> NSMutableSet {
        return self.choices.mutableCopy() as! NSMutableSet
    }

    @NSManaged open
    var planAccount: CD_MembershipPlanAccount?

}

extension _CD_AddField {

    open func addChoices(_ objects: NSSet) {
        let mutable = self.choices.mutableCopy() as! NSMutableSet
        mutable.union(objects as Set<NSObject>)
        self.choices = mutable.copy() as! NSSet
    }

    open func removeChoices(_ objects: NSSet) {
        let mutable = self.choices.mutableCopy() as! NSMutableSet
        mutable.minus(objects as Set<NSObject>)
        self.choices = mutable.copy() as! NSSet
    }

    open func addChoicesObject(_ value: CD_FieldChoice) {
        let mutable = self.choices.mutableCopy() as! NSMutableSet
        mutable.add(value)
        self.choices = mutable.copy() as! NSSet
    }

    open func removeChoicesObject(_ value: CD_FieldChoice) {
        let mutable = self.choices.mutableCopy() as! NSMutableSet
        mutable.remove(value)
        self.choices = mutable.copy() as! NSSet
    }

}

