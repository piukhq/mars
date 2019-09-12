//
//  MembershipCardModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import DeepDiff

extension DiffAware where Self: Hashable {
    public var diffId: Int {
        return hashValue
    }

    public static func compareContent(_ a: Self, _ b: Self) -> Bool {
        return a == b
    }
}

struct MembershipCardModel: Codable, Hashable, DiffAware {
    static func == (lhs: MembershipCardModel, rhs: MembershipCardModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(membershipTransactions)
        hasher.combine(status)
        hasher.combine(card)
        hasher.combine(images)
        hasher.combine(account)
        hasher.combine(paymentCards)
        hasher.combine(balances)
    }
    
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
