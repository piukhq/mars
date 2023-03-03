//
//  WhatsNewSwiftUIView.swift
//  binkapp
//
//  Created by Sean Williams on 28/02/2023.
//  Copyright © 2023 Bink. All rights reserved.
//

import SwiftUI

struct WhatsNewSwiftUIView: View {
    @ObservedObject var viewModel: WhatsNewViewModel
    
    var body: some View {
        ScrollView {
            if let merchants = viewModel.merchants {
                ForEach(merchants) { merchant in
                    NewMerchantView(merchant: merchant)
                }
            }
            
            if let features = viewModel.features {
                ForEach(features) { feature in
                    NewFeatureView(feature: feature)
                }
            }
            
            Spacer()
        }
        .padding(.top, 20)
        .background(Color(uiColor: Current.themeManager.color(for: .viewBackground)))
        .navigationTitle("What's New?")
    }
}

struct WhatsNewSwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            let merchant = NewMerchantModel(id: "207", description: ["Check out out lastest new merchant", "Sign up for a card in out app"])
            let feature = NewFeatureModel(title: "New Feature", description: "Check out this mint new feature yo.", screen: 0)
            let feature2 = NewFeatureModel(title: "New Feature", description: "Check out this mint new feature yo.", screen: 0)
            WhatsNewSwiftUIView(viewModel: WhatsNewViewModel(features: [feature, feature2], merchants: [merchant]))
        }
    }
}
