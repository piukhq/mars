//
//  WhatsNewSwiftUIView.swift
//  binkapp
//
//  Created by Sean Williams on 28/02/2023.
//  Copyright © 2023 Bink. All rights reserved.
//

import SwiftUI

struct WhatsNewSwiftUIView: View {
    @ObservedObject var viewModel = WhatsNewViewModel()
    
    var body: some View {
        if let merchants = viewModel.merchants {
            ForEach(merchants, id: \.self) { merchant in
                Text(String(merchant))
            }
        }
        
        if let features = viewModel.features {
            ForEach(features) { feature in
                NewFeatureView(feature: feature)
            }
        }
    }
}

struct NewFeatureView: View {
    var feature: NewFeatureModel
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25, style: .continuous)
                .fill(Color(Current.themeManager.color(for: .walletCardBackground)))
                .frame(height: 200)
                .foregroundColor(Color(Current.themeManager.color(for: .walletCardBackground)))
            VStack {
                Text(feature.title ?? "Title")
                Text(feature.description ?? "This summary, which briefly sets out your rights and obligations in relation to administration charges")
            }
        }
    }
}

struct WhatsNewSwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        WhatsNewSwiftUIView()
    }
}
