//
//  FeatureSetModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import CoreData

struct FeatureSetModel: Codable {
    enum PlanCardType: Int, Codable {
        case store
        case view
        case link
    }

    let apiId: Int?
    let authorisationRequired: Bool?
    let transactionsAvailable: Bool?
    let digitalOnly: Bool?
    let hasPoints: Bool?
    let cardType: PlanCardType?
    let linkingSupport: [String]? // TODO
    
    enum CodingKeys: String, CodingKey {
        case apiId = "id"
        case authorisationRequired = "authorisation_required"
        case transactionsAvailable = "transactions_available"
        case digitalOnly = "digital_only"
        case hasPoints = "has_points"
        case cardType = "card_type"
        case linkingSupport = "linking_support"
    }
}

extension FeatureSetModel: CoreDataMappable, CoreDataIDMappable {
    func objectToMapTo(_ cdObject: CD_FeatureSet, in context: NSManagedObjectContext, delta: Bool, overrideID: String?) -> CD_FeatureSet {
        update(cdObject, \.id, with: id, delta: delta)
        update(cdObject, \.authorisationRequired, with: NSNumber(value: authorisationRequired ?? false), delta: delta)
        update(cdObject, \.transactionsAvailable, with: NSNumber(value: transactionsAvailable ?? false), delta: delta)
        update(cdObject, \.digitalOnly, with: NSNumber(value: digitalOnly ?? false), delta: delta)
        update(cdObject, \.hasPoints, with: NSNumber(value: hasPoints ?? false), delta: delta)
        update(cdObject, \.cardType, with: NSNumber(value: cardType?.rawValue ?? 0), delta: delta)

        return cdObject
    }
}
