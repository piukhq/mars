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
    @Published var merchants: [NewMerchantModel]?
    
    init(features: [NewFeatureModel]?, merchants: [NewMerchantModel]?) {
        self.features = features
        self.merchants = merchants
    }
}
