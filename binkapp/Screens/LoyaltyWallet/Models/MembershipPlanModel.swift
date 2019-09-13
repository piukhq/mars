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

        if let featureSet = featureSet {
//            let overrideID = BowserResponse.idWith(override: id)
            let cdFeatureSet = featureSet.mapToCoreData(context, .update, overrideID: "")
            update(cdFeatureSet, \.plan, with: cdObject, delta: delta)
            update(cdObject, \.featureSet, with: cdFeatureSet, delta: delta)
        } else {
            update(cdObject, \.featureSet, with: nil, delta: false)
        }

        images?.forEach { image in
            let cdImage = image.mapToCoreData(context, .update, overrideID: nil)
            update(cdImage, \.plan, with: cdObject, delta: delta)
            cdObject.addImagesObject(cdImage)
        }

        if let account = account {
//            let overrideID = BowserResponse.idWith(override: id)
            let cdAccount = account.mapToCoreData(context, .update, overrideID: "")
            update(cdAccount, \.membershipPlan, with: cdObject, delta: delta)
            update(cdObject, \.account, with: cdAccount, delta: delta)
        } else {
            update(cdObject, \.account, with: nil, delta: false)
        }

        balances?.forEach { balance in
            let cdBalance = balance.mapToCoreData(context, .update, overrideID: nil)
            update(cdBalance, \.plan, with: cdObject, delta: delta)
            cdObject.addBalancesObject(cdBalance)
        }

        return cdObject
    }
}
