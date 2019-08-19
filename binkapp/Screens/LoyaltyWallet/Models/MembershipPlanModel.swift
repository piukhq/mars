//
//  MembershipPlanModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

struct MembershipPlanModel : Codable {
    let id : Int?
    let status : String?
    let featureSet : [String : FeatureSetModel]?
    let images : [MembershipCardImageModel]?
    let account : MemebershipPlanAccountModel?
    let balances : [BalanceModel]?
}
