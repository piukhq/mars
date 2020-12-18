//
//  CoreDataRepositoryProtocol.swift
//  binkapp
//
//  Created by Nick Farrant on 20/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import CoreData

/// A protocol that repository classes can conform to in order to easily interact with core data objects
protocol CoreDataRepositoryProtocol {
    func mapCoreDataObjects<T: CoreDataMappable, E>(objectsToMap objects: [T], type: E.Type, completion: @escaping () -> Void) where E: CD_BaseObject
    func fetchCoreDataObjects<T: NSManagedObject>(forObjectType objectType: T.Type, completion: @escaping ([T]?) -> Void)
    func fetchCoreDataObjects<T: NSManagedObject>(forObjectType objectType: T.Type, predicate: NSPredicate?, completion: @escaping ([T]?) -> Void)
    func trashLocalObjects<T: NSManagedObject>(forObjectType objectType: T.Type, completion: @escaping () -> Void)
}

extension CoreDataRepositoryProtocol {
    func mapCoreDataObjects<T: CoreDataMappable, E>(objectsToMap objects: [T], type: E.Type, completion: @escaping () -> Void) where E: CD_BaseObject {
        Current.database.performTask { context in
            var recordsToDelete = context.fetchAll(type) // Get all our records of this type
            
            // Get apiIds of remote wallet
            let ids = objects.compactMap { $0.id }
            
            ids.forEach { apiId in
                // For each id we get from the api, check if we have the id stored locally
                // If we do, remove the first instance of it (leaving any possible duplicates of that id) from the recordsToDelete array, therefore keeping the object
                if let index = recordsToDelete.firstIndex(where: { $0.id == apiId }) {
                    recordsToDelete.remove(at: index)
                }
            }
            
            Current.database.performBackgroundTask { backgroundContext in
                objects.forEach {
                    _ = $0.mapToCoreData(backgroundContext, .update, overrideID: nil)
                }
                
                if !recordsToDelete.isEmpty {
                    let managedObjectIds = recordsToDelete.map { $0.objectID }
                    
                    managedObjectIds.forEach { id in
                        if let object = backgroundContext.fetchWithID(type, id: id) {
                            backgroundContext.delete(object)
                        }
                    }
                }
                
                try? backgroundContext.save()
                
                DispatchQueue.main.async {
                    completion()
                }
            }
        }
    }
    
    func fetchCoreDataObjects<T: NSManagedObject>(forObjectType objectType: T.Type, completion: @escaping ([T]?) -> Void) {
        fetchCoreDataObjects(forObjectType: objectType, predicate: nil, completion: completion)
    }

    func fetchCoreDataObjects<T: NSManagedObject>(forObjectType objectType: T.Type, predicate: NSPredicate?, completion: @escaping ([T]?) -> Void) {
        DispatchQueue.main.async {
            Current.database.performTask { context in
                let objects = context.fetchAll(objectType, predicate: predicate, sorting: [NSSortDescriptor(key: "id", ascending: false)])
                completion(objects)
            }
        }
    }

    func trashLocalObjects<T: NSManagedObject>(forObjectType objectType: T.Type, completion: @escaping () -> Void) {
        Current.database.performBackgroundTask { context in
            context.deleteAll(objectType)
            try? context.save()
            DispatchQueue.main.async {
                completion()
            }
        }
    }
}
