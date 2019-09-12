//
//  Database.swift
//  Max Woodhams
//
//  Created by Max Woodhams on 02/04/2019.
//  Copyright © 2019 Max Woodhams. All rights reserved.
//

import UIKit
import CoreData

/// The wrapper around Core Data that obfuscates preparing a persistent container and dealing directly
/// with context retrieval.
public class Database {
    
    // MARK: - Helpers
    
    public typealias ManagedObjectContext = (NSManagedObjectContext) -> Void
    public typealias ManagedObjectContextWithObject<O: NSManagedObject> = (NSManagedObjectContext, O?) -> Void
    
    
    // MARK: - Properties
    
    private let modelName: String
    private let bundle: Bundle?
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container: NSPersistentContainer
        
        if let bundle = bundle { // Will be set on unit test route
            guard let url = bundle.url(forResource: modelName, withExtension: ".momd"),
            let model = NSManagedObjectModel(contentsOf: url) else {
                fatalError("Cannot find and initialise model")
            }
            container = NSPersistentContainer(name: modelName, managedObjectModel: model)
        } else {
            container = NSPersistentContainer(name: modelName) // Read from main bundle
        }
        
        let storeConfig = NSPersistentStoreDescription()
        storeConfig.shouldMigrateStoreAutomatically = true
        storeConfig.shouldInferMappingModelAutomatically = true
        
        if UIApplication.isRunningUnitTests() {
            storeConfig.type = NSInMemoryStoreType
        } else {
            storeConfig.type = NSSQLiteStoreType
            let documents = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let storePath = documents.appendingPathComponent("\(modelName).sqlite")
            storeConfig.url = storePath
            
            DispatchQueue.main.async {
                // Needs to be dispatched to main otherwise we get cross thread errors
                print("Database initialised at: \(storePath)")
            }
        }
        
        container.persistentStoreDescriptions = [storeConfig]
        
        container.loadPersistentStores(completionHandler: { (_, error) in
            guard let error = error as NSError? else { return }
            fatalError("Unresolved error: \(error), \(error.userInfo)")
        })
        
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.undoManager = nil
        container.viewContext.shouldDeleteInaccessibleFaults = true
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        return container
    }()
    
    var mainContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // MARK: - Initialisation
    
    public init(named name: String, inBundle: Bundle? = nil) {
        modelName = name
        bundle = inBundle
        persistentContainer.prepare()
    }
    
    // MARK: - Public Functions
    
    public func performTask(_ block: @escaping ManagedObjectContext) {
        assert(OperationQueue.current?.underlyingQueue == DispatchQueue.main, "Must be on the main queue")
        block(mainContext)
    }
    
    public func performTask<O: NSManagedObject>(with object: O, _ block: @escaping ManagedObjectContextWithObject<O>) {
        assert(OperationQueue.current?.underlyingQueue == DispatchQueue.main, "Must be on the main queue")
        let contextSafeObject = try? mainContext.existingObject(with: object.objectID) as? O
        block(mainContext, contextSafeObject)
    }
    
    public func performBackgroundTask(_ block: @escaping ManagedObjectContext) {
        persistentContainer.performBackgroundTask(block)
    }
    
    public func performBackgroundTask<O: NSManagedObject>(with object: O, _ block: @escaping ManagedObjectContextWithObject<O>) {
        persistentContainer.performBackgroundTask { context in
            let contextSafeObject = try? context.existingObject(with: object.objectID) as? O
            block(context, contextSafeObject)
        }
    }
    
    public func save() {
        if mainContext.hasChanges {
            do {
                try mainContext.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

// MARK: - Core Data Mappable

/// An enum that allows us to identify whether we are updating an object or not when mapping to Core Data
///
/// - none: Do not update the object. Delete if one exists and recreated. Gurantees a new object.
/// - update: Update the existing object fully with the data that is passed in
/// - delta: Update the existing object, replacing only the non-nil values that are passed in
public enum CoreDataUpdate {
    case none
    case update
    case delta
}

/// A protocol that allows an object to declare itself as mappable to Core Data
public protocol CoreDataMappable {
    
    /// The NSManagedObject type that this object can be mapped to. Inferred from methods below.
    associatedtype CoreDataObject: NSManagedObject
    
    /// The ID of the object. This typically is returned from the API and allows us to retrieve existing
    /// implementations of this object.
    var id: Int { get }
    
    /// **DO NOT IMPLEMENT**
    ///
    /// This method has an extension that provides the default implementation. By calling this method
    /// on a conforming type, a lookup is performed to retrieve the existing object. The objectToMapTo
    /// method is called with either a new instance of the object or the existing entity to update.
    ///
    /// - Parameters:
    ///   - context: The NSManagedObjectContex to execute Core Data methods in
    ///   - update: CoreDataUpdate enum stating the update type
    ///   - overrideID: An optional String which overrides the protocols "id" field. Used when an object has no logical ID
    /// - Returns: An NSManagedObject of the type this protocol represents
    func mapToCoreData(_ context: NSManagedObjectContext, _ update: CoreDataUpdate, overrideID: Int?) -> CoreDataObject
    
    /// **THIS IS THE ONLY METHOD YOU NEED TO IMPLEMENT**
    ///
    /// Note: Because the associated type CoreDataObject is passed and returned, implementing this method
    /// automatically sets the associatedType and therefore conforming objects don't need to specify it
    ///
    /// - Parameters:
    ///   - cdObject: The NSManagedObject for the properties to be mapped to
    ///   - context: The context in which to perform any additional Core Data executions (such as creating children)
    ///   - update: CoreDataUpdate enum stating the update type
    ///   - overrideID: An optional String which overrides the protocols "id" field. Used when an object has no logical ID
    /// - Returns: You must return from this method the cdObject that was passed in
    func objectToMapTo(_ cdObject: CoreDataObject, in context: NSManagedObjectContext, delta: Bool, overrideID: Int?) -> CoreDataObject
}

public extension CoreDataMappable {
    @discardableResult
    func mapToCoreData(_ context: NSManagedObjectContext, _ update: CoreDataUpdate, overrideID: Int?) -> CoreDataObject {
        var object: CoreDataObject?
        let existingObject = context.fetchWithApiID(CoreDataObject.self, id: overrideID ?? id)

        switch update {
        case .none:
            if let existingObject = existingObject {
                context.delete(existingObject)
            }
            object = CoreDataObject(context: context)
        case .update, .delta:
            object = existingObject ?? CoreDataObject(context: context) // Set to existing or create new
        }

        guard let mappableObject = object else {
            print("Could not map object: \(String(describing: self))")
            fatalError("This is an impossible state, bail")
        }

        switch update {
        case .none, .update:
            return objectToMapTo(mappableObject, in: context, delta: false, overrideID: overrideID)
        case .delta:
            return objectToMapTo(mappableObject, in: context, delta: true, overrideID: overrideID)
        }
    }
}

public extension CoreDataMappable {
    
    /// A convenience helper that powers the CoreDataUpdate style object mapping.
    ///
    /// - Parameters:
    ///   - object: The object we are updating (NSManagedObject subclass)
    ///   - keyPath: The keyPath to the property we are updating
    ///   - value: The value we are potentially setting on the object
    ///   - delta: A bool stating whether this is a delta update. If it is, update only if non-nil, otherwise always set.
    func update<Object: AnyObject, Value>(_ object: Object,
                                          _ keyPath: ReferenceWritableKeyPath<Object, Value?>,
                                          with value: Value?,
                                          delta: Bool) {
        if delta {
            object[keyPath: keyPath] = value ?? object[keyPath: keyPath]
        } else {
            object[keyPath: keyPath] = value
        }
    }
}
