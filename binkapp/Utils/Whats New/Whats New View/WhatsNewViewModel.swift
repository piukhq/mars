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
    @Published var backgroundColor = Color(uiColor: Current.themeManager.color(for: .viewBackground))
    
    init(features: [NewFeatureModel]?, merchants: [NewMerchantModel]?) {
        self.features = features
        self.merchants = merchants
        NotificationCenter.default.addObserver(self, selector: #selector(updateTheme), name: .themeManagerDidSetTheme, object: nil)
    }
    
    @objc func updateTheme() {
        backgroundColor = Color(uiColor: Current.themeManager.color(for: .viewBackground))
    }
}
