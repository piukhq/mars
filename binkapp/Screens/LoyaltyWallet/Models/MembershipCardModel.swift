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
    let paymentCards: [PaymentCard]?
    let membershipTransactions: [MembershipTransaction]?
    let status: MembershipCardStatusModel?
    let card: CardModel?
    let images: [MembershipCardImageModel]?
    let account: MembershipCardAccountModel?
    let balances: [MembershipCardBalanceModel]?
    
    enum CodingKeys: String, CodingKey {
        case apiId = "id"
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

extension MembershipCardModel: CoreDataMappable, CoreDataIDMappable {
    func objectToMapTo(_ cdObject: CD_MembershipCard, in context: NSManagedObjectContext, delta: Bool, overrideID: String?) -> CD_MembershipCard {
        update(cdObject, \.id, with: id, delta: delta)
        update(cdObject, \.membershipPlan, with: NSNumber(value: membershipPlan ?? 0), delta: delta)

        return cdObject
    }
}
