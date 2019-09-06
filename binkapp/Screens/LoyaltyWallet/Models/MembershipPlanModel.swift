//
//  MembershipPlanModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

struct MembershipPlanModel: Codable {
    let id: Int?
    let status: String?
    let featureSet: FeatureSetModel?
    let images: [MembershipCardImageModel]?
    let account: MemebershipPlanAccountModel?
    let balances: [BalanceModel]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case status
        case featureSet = "feature_set"
        case images
        case account
        case balances
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(Int.self, forKey: .id)
        status = try values.decodeIfPresent(String.self, forKey: .status)
        featureSet = try values.decodeIfPresent(FeatureSetModel.self, forKey: .featureSet)
        images = try values.decodeIfPresent([MembershipCardImageModel].self, forKey: .images)
        account = try values.decodeIfPresent(MemebershipPlanAccountModel.self, forKey: .account)
        balances = try values.decodeIfPresent([BalanceModel].self, forKey: .balances)
    }
}
