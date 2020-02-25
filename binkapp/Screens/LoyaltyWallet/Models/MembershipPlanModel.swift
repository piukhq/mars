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
    let images: [MembershipPlanImageModel]?
    let account: MembershipPlanAccountModel?
    let balances: [BalanceModel]?
    let hasVouchers: Bool?
    let dynamicContent: [DynamicContentField]?
    
    enum CodingKeys: String, CodingKey {
        case apiId = "id"
        case status
        case featureSet = "feature_set"
        case images
        case account
        case balances
        case hasVouchers = "has_vouchers"
        case dynamicContent = "content"
    }
}

extension MembershipPlanModel: CoreDataMappable, CoreDataIDMappable {
    func objectToMapTo(_ cdObject: CD_MembershipPlan, in context: NSManagedObjectContext, delta: Bool, overrideID: String?) -> CD_MembershipPlan {
        update(cdObject, \.id, with: overrideID ?? id, delta: delta)
        update(cdObject, \.status, with: status, delta: delta)
        update(cdObject, \.hasVouchers, with: NSNumber(value: hasVouchers ?? false), delta: delta)

        if let featureSet = featureSet {
            let cdFeatureSet = featureSet.mapToCoreData(context, .update, overrideID: FeatureSetModel.overrideId(forParentId: overrideID ?? id))
            update(cdFeatureSet, \.plan, with: cdObject, delta: delta)
            update(cdObject, \.featureSet, with: cdFeatureSet, delta: delta)
        } else {
            update(cdObject, \.featureSet, with: nil, delta: false)
        }

        cdObject.images.forEach {
            guard let image = $0 as? CD_MembershipPlanImage else { return }
            context.delete(image)
        }
        
        images?.forEach { image in
            let cdImage = image.mapToCoreData(context, .update, overrideID: nil)
            update(cdImage, \.plan, with: cdObject, delta: delta)
            cdObject.addImagesObject(cdImage)
        }

        if let account = account {
            let cdAccount = account.mapToCoreData(context, .update, overrideID: MembershipPlanAccountModel.overrideId(forParentId: overrideID ?? id))
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
            let cdBalance = balance.mapToCoreData(context, .update, overrideID: nil)
            update(cdBalance, \.plan, with: cdObject, delta: delta)
            cdObject.addBalancesObject(cdBalance)
        }


        cdObject.dynamicContent.forEach {
            guard let contentObject = $0 as? CD_PlanDynamicContent else { return }
            context.delete(contentObject)
        }
        dynamicContent?.forEach { contentObject in
            let cdContentObject = contentObject.mapToCoreData(context, .update, overrideID: nil)
            update(cdContentObject, \.plan, with: cdObject, delta: delta)
            cdObject.addDynamicContentObject(cdContentObject)
        }

        return cdObject
    }
}
