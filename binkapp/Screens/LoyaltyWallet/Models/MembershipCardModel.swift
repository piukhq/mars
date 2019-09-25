//
//  MembershipCardModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import CoreData
import DeepDiff

struct MembershipCardModel: Codable {
    let apiId: Int?
    let membershipPlan: Int?
    let membershipTransactions: [MembershipTransaction]?
    let status: MembershipCardStatusModel?
    let card: CardModel?
    let images: [MembershipCardImageModel]?
    let account: MembershipCardAccountModel?
    let paymentCards: [PaymentCardModel]?
    let balances: [MembershipCardBalanceModel]?
    
    enum CodingKeys: String, CodingKey {
        case apiId = "id"
        case membershipPlan = "membership_plan"
        case membershipTransactions = "membership_transactions"
        case status
        case card
        case images
        case account
        case paymentCards = "payment_cards"
        case balances
    }
}

extension MembershipCardModel: CoreDataMappable, CoreDataIDMappable {
    func objectToMapTo(_ cdObject: CD_MembershipCard, in context: NSManagedObjectContext, delta: Bool, overrideID: String?) -> CD_MembershipCard {
        update(cdObject, \.id, with: overrideID ?? id, delta: delta)
//        update(cdObject, \.membershipPlan, with: NSNumber(value: membershipPlan ?? 0), delta: delta)

        // Retrieve Membership Plan
        
        if let planId = membershipPlan {
                let plan = context.fetchWithApiID(CD_MembershipPlan.self, id: String(planId))
                self.update(cdObject, \.membershipPlan, with: plan, delta: delta)
                plan?.addMembershipCardsObject(cdObject)
        }

        cdObject.transactions.forEach {
            guard let transaction = $0 as? CD_MembershipTransaction else { return }
            context.delete(transaction)
        }
        
        membershipTransactions?.forEach { transaction in
            let cdTransaction = transaction.mapToCoreData(context, .update, overrideID: nil)
            cdObject.addTransactionsObject(cdTransaction)
            update(cdTransaction, \.card, with: cdObject, delta: false)
        }

        if let status = status {
            let cdStatus = status.mapToCoreData(context, .update, overrideID: MembershipCardStatusModel.overrideId(forParentId: id))
            update(cdStatus, \.card, with: cdObject, delta: delta)
            update(cdObject, \.status, with: cdStatus, delta: delta)
        } else {
            update(cdObject, \.status, with: nil, delta: false)
        }

        if let card = card {
            let cdCard = card.mapToCoreData(context, .update, overrideID: CardModel.overrideId(forParentId: id))
            update(cdCard, \.membershipCard, with: cdObject, delta: delta)
            update(cdObject, \.card, with: cdCard, delta: delta)
        } else {
            update(cdObject, \.card, with: nil, delta: false)
        }


        cdObject.images.forEach {
            guard let image = $0 as? CD_MembershipCardImage else { return }
            context.delete(image)
        }
        
        images?.forEach { image in
            let cdImage = image.mapToCoreData(context, .update, overrideID: nil)
            update(cdImage, \.card, with: cdObject, delta: delta)
            cdObject.addImagesObject(cdImage)
        }

        if let account = account {
            let cdAccount = account.mapToCoreData(context, .update, overrideID: MembershipCardAccountModel.overrideId(forParentId: id))
            update(cdAccount, \.card, with: cdObject, delta: delta)
            update(cdObject, \.account, with: cdAccount, delta: delta)
        } else {
            update(cdObject, \.account, with: nil, delta: false)
        }

        cdObject.paymentCards.forEach {
            guard let paymentCard = $0 as? CD_PaymentCard else { return }
            context.delete(paymentCard)
        }
        paymentCards?.forEach { paymentCard in
            let cdPaymentCard = paymentCard.mapToCoreData(context, .update, overrideID: nil)
            update(cdPaymentCard, \.membershipCard, with: cdObject, delta: delta)
            cdObject.addPaymentCardsObject(cdPaymentCard)
        }

        cdObject.balances.forEach {
            guard let balance = $0 as? CD_MembershipCardBalance else { return }
            context.delete(balance)
        }
        
        balances?.forEach { balance in
            let cdBalance = balance.mapToCoreData(context, .update, overrideID: MembershipCardModel.overrideId(forParentId: id))
            update(cdBalance, \.card, with: cdObject, delta: false)
            cdObject.addBalancesObject(cdBalance)
        }

        return cdObject
    }
}
