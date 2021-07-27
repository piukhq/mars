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
    var featureSet: FeatureSetModel?
    let images: [MembershipPlanImageModel]?
    var account: MembershipPlanAccountModel?
    let balances: [BalanceModel]?
    var dynamicContent: [DynamicContentField]?
    var hasVouchers: Bool?
    let card: CardModel?
    
    enum CodingKeys: String, CodingKey {
        case apiId = "id"
        case status
        case featureSet = "feature_set"
        case images
        case account
        case balances
        case dynamicContent = "content"
        case hasVouchers = "has_vouchers"
        case card
    }
}

extension MembershipPlanModel: Equatable {
    static func == (lhs: MembershipPlanModel, rhs: MembershipPlanModel) -> Bool {
        return lhs.id == rhs.id
    }
}

extension MembershipPlanModel: CoreDataMappable, CoreDataIDMappable {
    func objectToMapTo(_ cdObject: CD_MembershipPlan, in context: NSManagedObjectContext, delta: Bool, overrideID: String?) -> CD_MembershipPlan {
        update(cdObject, \.id, with: overrideID ?? id, delta: delta)
        update(cdObject, \.status, with: status, delta: delta)
        update(cdObject, \.hasVouchers, with: NSNumber(value: hasVouchers ?? false), delta: delta)

        if var featureSet = featureSet {
            if let planId = apiId, let agent = Current.pointsScrapingManager.agent(forPlanId: planId) {
                /// If we have a local points collection agent set for this plan, we should check that it is enabled on remote config
                if Current.pointsScrapingManager.agentEnabled(agent) {
                    /// If enabled on remote config, set to View
                    featureSet.cardType = .view
                    featureSet.hasPoints = true
                } else {
                    /// If disabled on remote config, set to Store
                    featureSet.cardType = .store
                    featureSet.hasPoints = false
                }
                featureSet.transactionsAvailable = false
            }
            
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


        if let dynamicContent = dynamicContent {
            for (index, contentObject) in dynamicContent.enumerated() {
                let indexID = DynamicContentField.overrideId(forParentId: overrideID ?? id) + String(index)
                let cdContentObject = contentObject.mapToCoreData(context, .update, overrideID: indexID)
                update(cdContentObject, \.plan, with: cdObject, delta: delta)
                cdObject.addDynamicContentObject(cdContentObject)
            }
        }

        if let card = card {
            let cdCard = card.mapToCoreData(context, .update, overrideID: CardModel.overrideId(forParentId: overrideID ?? id))
            update(cdCard, \.membershipPlan, with: cdObject, delta: delta)
            update(cdObject, \.card, with: cdCard, delta: delta)
        } else {
            update(cdObject, \.card, with: nil, delta: false)
        }

        return cdObject
    }
}
