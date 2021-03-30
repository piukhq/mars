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
        case comingSoon
    }

    let apiId: Int?
    let authorisationRequired: Bool?
    let transactionsAvailable: Bool?
    let digitalOnly: Bool?
    let hasPoints: Bool?
    let cardType: PlanCardType?
    let linkingSupport: [LinkingSupportType]?
    let hasVouchers: Bool?
    
    enum CodingKeys: String, CodingKey {
        case apiId = "id"
        case authorisationRequired = "authorisation_required"
        case transactionsAvailable = "transactions_available"
        case digitalOnly = "digital_only"
        case hasPoints = "has_points"
        case cardType = "card_type"
        case linkingSupport = "linking_support"
        case hasVouchers = "has_vouchers"
    }
}

extension FeatureSetModel: CoreDataMappable, CoreDataIDMappable {
    func objectToMapTo(_ cdObject: CD_FeatureSet, in context: NSManagedObjectContext, delta: Bool, overrideID: String?) -> CD_FeatureSet {
        update(cdObject, \.id, with: overrideID ?? id, delta: delta)
        update(cdObject, \.authorisationRequired, with: NSNumber(value: authorisationRequired ?? false), delta: delta)
        update(cdObject, \.transactionsAvailable, with: NSNumber(value: transactionsAvailable ?? false), delta: delta)
        update(cdObject, \.digitalOnly, with: NSNumber(value: digitalOnly ?? false), delta: delta)
        update(cdObject, \.hasPoints, with: NSNumber(value: hasPoints ?? false), delta: delta)
        update(cdObject, \.cardType, with: NSNumber(value: cardType?.rawValue ?? 0), delta: delta)
        update(cdObject, \.hasVouchers, with: NSNumber(value: hasVouchers ?? false), delta: delta)

        cdObject.linkingSupport.forEach {
            guard let support = $0 as? CD_LinkingSupport else { return }
            context.delete(support)
        }

        if let linkingSupport = linkingSupport {
            for (index, support) in linkingSupport.enumerated() {
                let indexID = LinkingSupportType.overrideId(forParentId: overrideID ?? id) + String(index)
                let cdSupport = support.mapToCoreData(context, .update, overrideID: indexID)
                update(cdSupport, \.featureSet, with: cdObject, delta: delta)
                cdObject.addLinkingSupportObject(cdSupport)
            }
        }

        return cdObject
    }
}
