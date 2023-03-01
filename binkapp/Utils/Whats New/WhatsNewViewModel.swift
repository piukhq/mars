//
//  WhatsNewViewModel.swift
//  binkapp
//
//  Created by Sean Williams on 28/02/2023.
//  Copyright © 2023 Bink. All rights reserved.
//

import SwiftUI

class WhatsNewViewModel: ObservableObject {
    @Published var features: [NewFeatureModel]?
    @Published var merchants: [Int]?
    
    init(features: [NewFeatureModel]?, merchants: [Int]?) {
        self.features = features
        self.merchants = merchants
    }
}
