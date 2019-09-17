//
//  MembershipCardModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import CoreData

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
        update(cdObject, \.id, with: id, delta: delta)


        if let membershipPlanId = membershipPlan {
            // Mock the plan response from the plan id we have so that we can map correctly
            let plan = MembershipPlanModel(apiId: membershipPlanId, status: nil, featureSet: nil, images: nil, account: nil, balances: nil)

            let overrideID = ""
            let cdMembershipPlan = plan.mapToCoreData(context, .update, overrideID: overrideID)
            update(cdMembershipPlan, \.membershipCard, with: cdObject, delta: delta)
            update(cdObject, \.membershipPlan, with: cdMembershipPlan, delta: delta)
        } else {
            update(cdObject, \.membershipPlan, with: nil, delta: false)
        }


        cdObject.transactions.forEach {
            guard let transaction = $0 as? CD_MembershipTransaction else { return }
            context.delete(transaction)
        }
        membershipTransactions?.forEach { transaction in
            let cdTransaction = transaction.mapToCoreData(context, .update, overrideID: nil)
            update(cdTransaction, \.card, with: cdObject, delta: delta)
            cdObject.addTransactionsObject(cdTransaction)
        }


        if let status = status {
            let overrideID = ""
            let cdStatus = status.mapToCoreData(context, .update, overrideID: overrideID)
            update(cdStatus, \.card, with: cdObject, delta: delta)
            update(cdObject, \.status, with: cdStatus, delta: delta)
        } else {
            update(cdObject, \.status, with: nil, delta: false)
        }


        if let card = card {
            let overrideID = ""
            let cdCard = card.mapToCoreData(context, .update, overrideID: overrideID)
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
            let overrideID = ""
            let cdAccount = account.mapToCoreData(context, .update, overrideID: overrideID)
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
            let cdBalance = balance.mapToCoreData(context, .update, overrideID: nil)
            update(cdBalance, \.card, with: cdObject, delta: delta)
            cdObject.addBalancesObject(cdBalance)
        }
        

        return cdObject
    }
}
