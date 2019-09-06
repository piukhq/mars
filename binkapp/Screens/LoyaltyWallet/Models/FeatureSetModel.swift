//
//  FeatureSetModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

struct FeatureSetModel: Codable {
    let authorisationRequired: Bool?
    let transactionsAvailable: Bool?
    let digitalOnly: Bool?
    let hasPoints: Bool?
    let cardType: Int?
    let linkingSupport: [String]?
//    let apps: [String]?
    
    enum CodingKeys: String, CodingKey {
        case authorisationRequired = "authorisation_required"
        case transactionsAvailable = "transactions_available"
        case digitalOnly = "digital_only"
        case hasPoints = "has_points"
        case cardType = "card_type"
        case linkingSupport = "linking_support"
//        case apps = "apps"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        authorisationRequired = try values.decodeIfPresent(Bool.self, forKey: .authorisationRequired)
        transactionsAvailable = try values.decodeIfPresent(Bool.self, forKey: .transactionsAvailable)
        digitalOnly = try values.decodeIfPresent(Bool.self, forKey: .digitalOnly)
        hasPoints = try values.decodeIfPresent(Bool.self, forKey: .hasPoints)
        cardType = try values.decodeIfPresent(Int.self, forKey: .cardType)
        linkingSupport = try values.decodeIfPresent([String].self, forKey: .linkingSupport)
//        apps = try values.decodeIfPresent([String].self, forKey: .apps)
    }
}
