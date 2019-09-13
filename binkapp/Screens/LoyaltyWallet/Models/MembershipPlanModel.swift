//
//  MembershipPlanModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import CoreData

struct MembershipPlanModel: Codable {
    let apiId: Int?
    let status: String?
    let featureSet: FeatureSetModel?
    let images: [MembershipCardImageModel]?
    let account: MembershipPlanAccountModel?
    let balances: [BalanceModel]?
    
    enum CodingKeys: String, CodingKey {
        case apiId = "id"
        case status
        case featureSet = "feature_set"
        case images
        case account
        case balances
    }
}

extension MembershipPlanModel: CoreDataMappable, CoreDataIDMappable {
    func objectToMapTo(_ cdObject: CD_MembershipPlan, in context: NSManagedObjectContext, delta: Bool, overrideID: String?) -> CD_MembershipPlan {
        update(cdObject, \.id, with: id, delta: delta)
        update(cdObject, \.status, with: status, delta: delta)

        return cdObject
    }
}
