//
//  WhatsNewModel.swift
//  binkapp
//
//  Created by Sean Williams on 28/02/2023.
//  Copyright © 2023 Bink. All rights reserved.
//

import Foundation

struct WhatsNewModel: Codable {
    var appVersion: String?
    let merchants: [NewMerchantModel]?
    let features: [NewFeatureModel]?
    
    enum CodingKeys: String, CodingKey {
        case appVersion = "app_version"
        case merchants
        case features
    }
}

struct NewMerchantModel: Codable, Identifiable {
    var id: String?
    let description: [String]?
}

struct NewFeatureModel: Codable, Identifiable {
    var id: String?
    let title: String?
    let description: [String]?
    var screen: Int?
    let imageUrl: String?
}
