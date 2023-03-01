//
//  WhatsNewModel.swift
//  binkapp
//
//  Created by Sean Williams on 28/02/2023.
//  Copyright © 2023 Bink. All rights reserved.
//

import Foundation

struct WhatsNewModel: Codable {
    let merchants: [Int]?
    let features: [NewFeatureModel]?
}

struct NewFeatureModel: Codable, Identifiable {
    var id = UUID()
    let title: String?
    let description: String?
    let url: String?
}
