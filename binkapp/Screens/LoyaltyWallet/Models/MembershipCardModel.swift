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
    let paymentCards: [String]?
    let membershipTransactions: [MembershipTransaction]?
    let status: MembershipCardStatusModel?
    let card: CardModel?
    let images: [MembershipCardImageModel]?
    let account: MembershipCardAccountModel?
    let balances: [MembershipCardBalanceModel]?
    
    enum CodingKeys: String, CodingKey {
        
        case id = "id"
        case membershipPlan = "membership_plan"
        case paymentCards = "payment_cards"
        case membershipTransactions = "membership_transactions"
        case status = "status"
        case card = "card"
        case images = "images"
        case account = "account"
        case balances = "balances"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(Int.self, forKey: .id)
        membershipPlan = try values.decodeIfPresent(Int.self, forKey: .membershipPlan)
        paymentCards = try values.decodeIfPresent([String].self, forKey: .paymentCards)
        membershipTransactions = try values.decodeIfPresent([MembershipTransaction].self, forKey: .membershipTransactions)
        status = try values.decodeIfPresent(MembershipCardStatusModel.self, forKey: .status)
        card = try values.decodeIfPresent(CardModel.self, forKey: .card)
        images = try values.decodeIfPresent([MembershipCardImageModel].self, forKey: .images)
        account = try values.decodeIfPresent(MembershipCardAccountModel.self, forKey: .account)
        balances = try values.decodeIfPresent([MembershipCardBalanceModel].self, forKey: .balances)
    }
}
