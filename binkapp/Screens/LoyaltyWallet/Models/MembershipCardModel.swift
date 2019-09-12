//
//  MembershipCardModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import CoreData

struct MembershipCardModel: Codable {
    let id: Int?
    let membershipPlan: Int?
    let paymentCards: [PaymentCard]?
    let membershipTransactions: [MembershipTransaction]?
    let status: MembershipCardStatusModel?
    let card: CardModel?
    let images: [MembershipCardImageModel]?
    let account: MembershipCardAccountModel?
    let balances: [MembershipCardBalanceModel]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case membershipPlan = "membership_plan"
        case paymentCards = "payment_cards"
        case membershipTransactions = "membership_transactions"
        case status
        case card
        case images
        case account
        case balances
    }
}

extension MembershipCardModel: CoreDataMappable {
    func objectToMapTo(_ cdObject: CD_MembershipCard, in context: NSManagedObjectContext, delta: Bool, overrideID: Int?) -> CD_MembershipCard {
        // Our codable models all need to have id's as Int's as dictated by API responses
        // However, we want to cast these all to strings so that our core data wrapper remains unchanged.
        let idString = String(id ?? 0)

        update(cdObject, \.id, with: idString, delta: delta)
        update(cdObject, \.membershipPlan, with: NSNumber(value: membershipPlan ?? 0), delta: delta)

        return cdObject
    }
}
