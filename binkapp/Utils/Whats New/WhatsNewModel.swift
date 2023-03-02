//
//  WhatsNewModel.swift
//  binkapp
//
//  Created by Sean Williams on 28/02/2023.
//  Copyright © 2023 Bink. All rights reserved.
//

import Foundation

struct WhatsNewModel: Codable {
    let merchants: [NewMerchantModel]?
    let features: [NewFeatureModel]?
}

struct NewMerchantModel: Codable, Identifiable {
    var id: String?
    let description: [String]?
    let url: String?
}

struct NewFeatureModel: Codable, Identifiable {
    var id: String? = UUID().uuidString
    let title: String?
    let description: String?
    let url: String?
}
