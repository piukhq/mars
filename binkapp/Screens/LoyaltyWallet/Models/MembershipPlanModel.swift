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
        update(cdObject, \.id, with: id(orOverrideId: overrideID), delta: delta)
        update(cdObject, \.status, with: status, delta: delta)


        if let featureSet = featureSet {
            let cdFeatureSet = featureSet.mapToCoreData(context, .update, overrideID: FeatureSetModel.overrideId(forParentId: id))
            update(cdFeatureSet, \.plan, with: cdObject, delta: delta)
            update(cdObject, \.featureSet, with: cdFeatureSet, delta: delta)
        } else {
            update(cdObject, \.featureSet, with: nil, delta: false)
        }


        cdObject.images.forEach {
            guard let image = $0 as? CD_MembershipCardImage else { return }
            context.delete(image)
        }
        images?.forEach { image in
            let overrideId = MembershipCardImageModel.overrideId(forParentId: id(orOverrideId: overrideID), withExtension: image.id)
            let cdImage = image.mapToCoreData(context, .update, overrideID: overrideId)
            update(cdImage, \.plan, with: cdObject, delta: delta)
            cdObject.addImagesObject(cdImage)
        }


        if let account = account {
            let cdAccount = account.mapToCoreData(context, .update, overrideID: MembershipPlanAccountModel.overrideId(forParentId: id))
            update(cdAccount, \.plan, with: cdObject, delta: delta)
            update(cdObject, \.account, with: cdAccount, delta: delta)
        } else {
            update(cdObject, \.account, with: nil, delta: false)
        }


        cdObject.balances.forEach {
            guard let balance = $0 as? CD_Balance else { return }
            context.delete(balance)
        }
        balances?.forEach { balance in
            let overrideId = BalanceModel.overrideId(forParentId: id(orOverrideId: overrideID), withExtension: balance.id)
            let cdBalance = balance.mapToCoreData(context, .update, overrideID: overrideId)
            update(cdBalance, \.plan, with: cdObject, delta: delta)
            cdObject.addBalancesObject(cdBalance)
        }


        return cdObject
    }
}
