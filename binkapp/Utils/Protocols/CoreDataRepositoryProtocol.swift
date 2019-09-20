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
    func mapCoreDataObjects<T: CoreDataMappable>(objectsToMap objects: [T], completion: @escaping () -> Void)
    func fetchCoreDataObjects<T: NSManagedObject>(forObjectType objectType: T.Type, completion: @escaping ([T]?) -> Void)
    func trashLocalObjects<T: NSManagedObject>(forObjectType objectType: T.Type, completion: @escaping () -> Void)
}

extension CoreDataRepositoryProtocol {
    func mapCoreDataObjects<T: CoreDataMappable>(objectsToMap objects: [T], completion: @escaping () -> Void) {
        Current.database.performBackgroundTask { context in
            objects.forEach {
                _ = $0.mapToCoreData(context, .delta, overrideID: nil)
            }

            try? context.save()

            completion()
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

