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
    func trashLocalObjects<T: NSManagedObject>(forObjectType objectType: T.Type, completion: @escaping () -> Void)
}

extension CoreDataRepositoryProtocol {
    func mapCoreDataObjects<T: CoreDataMappable, E>(objectsToMap objects: [T], type: E.Type, completion: @escaping () -> Void) where E: CD_BaseObject {
        
        Current.database.performTask { context in
            var recordsToDelete = context.fetchAll(type) // Get all our records of this type
            
            // Get apiIds of remote wallet
            let ids = objects.compactMap { $0.id }
            
            recordsToDelete.removeAll(where: { ids.contains($0.id) })
            
            Current.database.performBackgroundTask { context in
                objects.forEach {
                    _ = $0.mapToCoreData(context, .none, overrideID: nil)
                }
                
                if !recordsToDelete.isEmpty {
                    let managedObjectIds = recordsToDelete.map { $0.objectID }
                    
                    managedObjectIds.forEach { id in
                        if let object = context.fetchWithID(type, id: id) {
                            context.delete(object)
                        }
                    }
                }
                
                try? context.save()
                
                DispatchQueue.main.async {
                    completion()
                }
            }
        }
    }

    func fetchCoreDataObjects<T: NSManagedObject>(forObjectType objectType: T.Type, completion: @escaping ([T]?) -> Void) {
        DispatchQueue.main.async {
            Current.database.performTask { context in
                let objects = context.fetchAll(objectType)
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

