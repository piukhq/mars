//
//  CoreDataTestable.swift
//  binkappTests
//
//  Created by Nick Farrant on 19/11/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import Foundation

/// A lightweight protocol that enables unit test classes to replicate the process of mapping an API response model to a Core Data managed object.
/// In doing so, we are accurately able to test view models which have managed object dependancies, rather than create and maintain mocked view models.
protocol CoreDataTestable {
    /// ** THIS METHOD SHOULD ONLY BE CALLED FROM THE STATIC SETUP FUNCTION **
    ///
    /// Map an API response model to a Core Data managed object. Static so that it can be run from ```class func setUp()```.
    /// - Parameters:
    ///   - responseModel: A stubbed replica of a typical API response model to be mapped to Core Data.
    ///   - managedObjectType: The Core Data managed object type to map to. Must conform to CoreDataMappable
    ///   - completion: A strongly typed managed object mapped from the response model.
    static func mapResponseToManagedObject<ResponseModel: CoreDataMappable, ManagedObjectType: CD_BaseObject>(_ responseModel: ResponseModel, managedObjectType: ManagedObjectType.Type, completion: @escaping (ManagedObjectType) -> Void)

    static func mapResponsesToManagedObjects<ResponseModel: CoreDataMappable, ManagedObjectType: CD_BaseObject>(_ responseModels: [ResponseModel], managedObjectType: ManagedObjectType.Type, completion: @escaping ([ManagedObjectType]) -> Void)
    
    /// ** THIS METHOD SHOULD ONLY BE CALLED FROM INSIDE TEST CASES WHEN IT IS NECESSARY TO MUTATE A BASE RESPONSE MODEL **
    ///
    /// Map an API response model to a Core Data managed object. Instance method so that it can be run inside test cases.
    /// - Parameters:
    ///   - responseModel: A stubbed replica of a typical API response model to be mapped to Core Data.
    ///   - managedObjectType: The Core Data managed object type to map to. Must conform to CoreDataMappable
    ///   - completion: A strongly typed managed object mapped from the response model.
    func mapResponseToManagedObject<ResponseModel: CoreDataMappable, ManagedObjectType: CD_BaseObject>(_ responseModel: ResponseModel, managedObjectType: ManagedObjectType.Type, completion: @escaping (ManagedObjectType) -> Void)
    
    func mapResponsesToManagedObjects<ResponseModel: CoreDataMappable, ManagedObjectType: CD_BaseObject>(_ responseModels: [ResponseModel], managedObjectType: ManagedObjectType.Type, completion: @escaping ([ManagedObjectType]) -> Void)
}

extension CoreDataTestable {
    static func mapResponseToManagedObject<ResponseModel: CoreDataMappable, ManagedObjectType: CD_BaseObject>(_ responseModel: ResponseModel, managedObjectType: ManagedObjectType.Type, completion: @escaping (ManagedObjectType) -> Void) {
        Current.database.performTask { context in
            let managedObject = responseModel.mapToCoreData(context, .update, overrideID: nil) as! ManagedObjectType
            completion(managedObject)
        }
    }
    
    static func mapResponsesToManagedObjects<ResponseModel: CoreDataMappable, ManagedObjectType: CD_BaseObject>(_ responseModels: [ResponseModel], managedObjectType: ManagedObjectType.Type, completion: @escaping ([ManagedObjectType]) -> Void) {
        Current.database.performTask { context in
            var managedObjects: [ManagedObjectType] = []
            responseModels.forEach {
                let managedObject = $0.mapToCoreData(context, .update, overrideID: nil) as! ManagedObjectType
                managedObjects.append(managedObject)
            }
//            try? context.save()
            completion(managedObjects)
        }
    }


    func mapResponseToManagedObject<ResponseModel: CoreDataMappable, ManagedObjectType: CD_BaseObject>(_ responseModel: ResponseModel, managedObjectType: ManagedObjectType.Type, completion: @escaping (ManagedObjectType) -> Void) {
        Current.database.performTask { context in
            let managedObject = responseModel.mapToCoreData(context, .update, overrideID: nil) as! ManagedObjectType
            completion(managedObject)
        }
    }
    
    func mapResponsesToManagedObjects<ResponseModel: CoreDataMappable, ManagedObjectType: CD_BaseObject>(_ responseModels: [ResponseModel], managedObjectType: ManagedObjectType.Type, completion: @escaping ([ManagedObjectType]) -> Void) {
        Current.database.performTask { context in
            var managedObjects: [ManagedObjectType] = []
            responseModels.forEach {
                let managedObject = $0.mapToCoreData(context, .update, overrideID: nil) as! ManagedObjectType
                managedObjects.append(managedObject)
            }
//            try? context.save()
            completion(managedObjects)
        }
    }

}
