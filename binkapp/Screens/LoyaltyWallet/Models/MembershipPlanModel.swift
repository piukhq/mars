//
//  MembershipPlanModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import CoreData

struct MembershipPlanModel: Codable {
    let id: Int
    let status: String?
    let featureSet: FeatureSetModel?
    let images: [MembershipCardImageModel]?
    let account: MembershipPlanAccountModel?
    let balances: [BalanceModel]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case status
        case featureSet = "feature_set"
        case images
        case account
        case balances
    }
}

extension MembershipPlanModel: CoreDataMappable {
    func objectToMapTo(_ cdObject: CD_MembershipPlan, in context: NSManagedObjectContext, delta: Bool, overrideID: Int?) -> CD_MembershipPlan {
        // Our codable models all need to have id's as Int's as dictated by API responses
        // However, we want to cast these all to strings so that our core data wrapper remains unchanged.
        let idString = String(id)

        update(cdObject, \.id, with: idString, delta: delta)
        update(cdObject, \.status, with: status, delta: delta)

        return cdObject
    }
}
