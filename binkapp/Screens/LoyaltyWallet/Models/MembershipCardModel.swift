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
    let paymentCards: [LinkedCardResponse]?
    let balances: [MembershipCardBalanceModel]?
    let vouchers: [VoucherModel]?
    
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
        case vouchers
    }
}

extension MembershipCardModel: CoreDataMappable, CoreDataIDMappable {
    func objectToMapTo(_ cdObject: CD_MembershipCard, in context: NSManagedObjectContext, delta: Bool, overrideID: String?) -> CD_MembershipCard {
        update(cdObject, \.id, with: overrideID ?? id, delta: delta)
        
        // UUID - Use the object's existing uuid or generate a new one at this point
        let uuid = cdObject.uuid ?? UUID().uuidString
        update(cdObject, \.uuid, with: uuid, delta: delta)

        // Retrieve Membership Plan
        
        if let planId = membershipPlan {
            // get plan for id from core data
            let plan = context.fetchWithApiID(CD_MembershipPlan.self, id: String(planId))

            // update membership card with this membership plan
            update(cdObject, \.membershipPlan, with: plan, delta: delta)

            // add this cd object to the plan
            plan?.addMembershipCardsObject(cdObject)
        }

        cdObject.transactions.forEach {
            guard let transaction = $0 as? CD_MembershipTransaction else { return }
            context.delete(transaction)
        }
                
        if let membershipTransactions = membershipTransactions {
            for (index, transaction) in membershipTransactions.enumerated() {
                let indexID = MembershipTransaction.overrideId(forParentId: overrideID ?? id) + String(index)
                let cdTransaction = transaction.mapToCoreData(context, .update, overrideID: indexID)
                cdObject.addTransactionsObject(cdTransaction)
                update(cdTransaction, \.card, with: cdObject, delta: false)
            }
        }

        if let status = status {
            if let existingStatus = cdObject.status?.status, status.state != existingStatus {
                BinkAnalytics.track(CardAccountAnalyticsEvent.loyaltyCardStatus(loyaltyCard: cdObject, newStatus: status.state))
            }
            
            let cdStatus = status.mapToCoreData(context, .update, overrideID: MembershipCardStatusModel.overrideId(forParentId: overrideID ?? id))
            update(cdStatus, \.card, with: cdObject, delta: delta)
            update(cdObject, \.status, with: cdStatus, delta: delta)
        } else {
            update(cdObject, \.status, with: nil, delta: false)
        }

        if let card = card {
            let cdCard = card.mapToCoreData(context, .update, overrideID: CardModel.overrideId(forParentId: overrideID ?? id))
            update(cdCard, \.membershipCard, with: cdObject, delta: delta)
            update(cdObject, \.card, with: cdCard, delta: delta)
        } else {
            update(cdObject, \.card, with: nil, delta: false)
        }


        cdObject.images.forEach {
            guard let image = $0 as? CD_MembershipCardImage else { return }
            context.delete(image)
        }
        if let images = images {
            for (index, image) in images.enumerated() {
                let indexID = MembershipCardImageModel.overrideId(forParentId: overrideID ?? id) + String(index)
                let cdImage = image.mapToCoreData(context, .update, overrideID: indexID)
                cdImage.addMembershipCardsObject(cdObject)
                cdObject.addImagesObject(cdImage)
            }
        }

        if let account = account {
            let cdAccount = account.mapToCoreData(context, .update, overrideID: MembershipCardAccountModel.overrideId(forParentId: overrideID ?? id))
            update(cdAccount, \.card, with: cdObject, delta: delta)
            update(cdObject, \.account, with: cdAccount, delta: delta)
        } else {
            update(cdObject, \.account, with: nil, delta: false)
        }

        cdObject.linkedPaymentCards.forEach {
            guard let paymentCard = $0 as? CD_PaymentCard else { return }
            cdObject.removeLinkedPaymentCardsObject(paymentCard)
        }
        paymentCards?.filter({ $0.activeLink == true }).forEach { paymentCard in
            if let cdPaymentCard = context.fetchWithApiID(CD_PaymentCard.self, id: String(paymentCard.id ?? 0)) {
                cdObject.addLinkedPaymentCardsObject(cdPaymentCard)
                cdPaymentCard.addLinkedMembershipCardsObject(cdObject)
            }
        }

        cdObject.balances.forEach {
            guard let balance = $0 as? CD_MembershipCardBalance else { return }
            context.delete(balance)
        }
        
        if let balances = balances {
            for (index, balance) in balances.enumerated() {
                let indexID = MembershipCardBalanceModel.overrideId(forParentId: overrideID ?? id) + String(index)
                let cdBalance = balance.mapToCoreData(context, .update, overrideID: indexID)
                update(cdBalance, \.card, with: cdObject, delta: false)
                cdObject.addBalancesObject(cdBalance)
            }
        }

        cdObject.vouchers.forEach {
            guard let voucher = $0 as? CD_Voucher else { return }
            context.delete(voucher)
        }

        if let vouchers = vouchers {
            for (index, voucher) in vouchers.enumerated() {
                let indexID = VoucherModel.overrideId(forParentId: overrideID ?? id) + String(index)
                let cdVoucher = voucher.mapToCoreData(context, .update, overrideID: indexID)
                update(cdVoucher, \.membershipCard, with: cdObject, delta: false)
                cdObject.addVouchersObject(cdVoucher)
            }
        }

        return cdObject
    }
}
