//
//  MembershipCardModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

struct MembershipCardModel: Codable {
    let id: Int?
    let membershipPlan: Int?
    let membershipTransactions: [MembershipTransaction]?
    let status: MembershipCardStatusModel?
    let card: CardModel?
    let images: [MembershipCardImageModel]?
    let account: MembershipCardAccountModel?
    let paymentCards: [PaymentCardModel]?
    let balances: [MembershipCardBalanceModel]?
    
    enum CodingKeys: String, CodingKey {
        
        case id = "id"
        case membershipPlan = "membership_plan"
        case membershipTransactions = "membership_transactions"
        case status = "status"
        case card = "card"
        case images = "images"
        case account = "account"
        case paymentCards = "payment_cards"
        case balances = "balances"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(Int.self, forKey: .id)
        membershipPlan = try values.decodeIfPresent(Int.self, forKey: .membershipPlan)
        membershipTransactions = try values.decodeIfPresent([MembershipTransaction].self, forKey: .membershipTransactions)
        status = try values.decodeIfPresent(MembershipCardStatusModel.self, forKey: .status)
        card = try values.decodeIfPresent(CardModel.self, forKey: .card)
        images = try values.decodeIfPresent([MembershipCardImageModel].self, forKey: .images)
        account = try values.decodeIfPresent(MembershipCardAccountModel.self, forKey: .account)
        paymentCards = try values.decodeIfPresent([PaymentCardModel].self, forKey: .paymentCards)
        balances = try values.decodeIfPresent([MembershipCardBalanceModel].self, forKey: .balances)
    }
}
