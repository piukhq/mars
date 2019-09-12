//
//  NSManagedObjectContext.swift
//  Max Woodhams
//
//  Created by Max Woodhams on 03/04/2019.
//  Copyright © 2019 Max Woodhams. All rights reserved.
//

import CoreData

public extension NSManagedObjectContext {
    
    func fetchWithID<T: NSManagedObject>(_ type: T.Type, id: NSManagedObjectID) -> T? {
        return object(with: id) as? T
    }
    
    func fetchWithApiID<T: NSManagedObject>(_ type: T.Type, id: Int) -> T? {
        let idString = String(id)
        let results = fetch(type, predicate: NSPredicate(format: "id == %@", idString))
        return results?.first
    }
    
    func fetch<T: NSManagedObject>(_ type: T.Type, predicate: NSPredicate? = nil, sorting: [NSSortDescriptor]? = nil) -> [T]? {
        guard let fetchRequest = fetchRequestFor(type) else {
            return nil
        }
        
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sorting
        
        return try? fetch(fetchRequest)
    }
    
    func countOfAll<T: NSManagedObject>(_ type: T.Type) -> Int {
        guard let fetchRequest = fetchRequestFor(type) else {
            return 0
        }
        
        do {
            return try count(for: fetchRequest)
        } catch {
            return 0
        }
    }
    
    func fetchAll<T: NSManagedObject>(_ type: T.Type, batch: Int? = nil, predicate: NSPredicate? = nil, sorting: [NSSortDescriptor]? = nil) -> [T] {
        guard let fetchRequest = fetchRequestFor(type) else {
            return []
        }
        
        if let batch = batch {
            fetchRequest.fetchLimit = batch
        }
        
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sorting
        
        do {
            return try fetch(fetchRequest)
        } catch {
            return []
        }
    }
    
    func deleteAll<T: NSManagedObject>(_ type: T.Type) {
        for entity in fetchAll(type) {
            delete(entity)
        }
    }
    
    private func fetchRequestFor<T: NSManagedObject>(_ type: T.Type) -> NSFetchRequest<T>? {
        guard let name = T.entity().name else {
            return nil
        }
        
        return NSFetchRequest<T>(entityName: name)
    }
}
