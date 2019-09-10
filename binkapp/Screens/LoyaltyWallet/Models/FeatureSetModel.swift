//
//  FeatureSetModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

struct FeatureSetModel: Codable {
    let id: String
    let authorisationRequired: Bool?
    let transactionsAvailable: Bool?
    let digitalOnly: Bool?
    let hasPoints: Bool?
    let cardType: Int?
    let linkingSupport: [String]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case authorisationRequired = "authorisation_required"
        case transactionsAvailable = "transactions_available"
        case digitalOnly = "digital_only"
        case hasPoints = "has_points"
        case cardType = "card_type"
        case linkingSupport = "linking_support"
    }
}
