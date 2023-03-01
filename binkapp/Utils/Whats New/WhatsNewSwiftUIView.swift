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
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .frame(height: 120)
                .foregroundColor(Color(.secondarySystemBackground))
//                .foregroundColor(Color(Current.themeManager.color(for: .text)))
            HStack {
                VStack(alignment: .leading, spacing: 10) {
                    Text(feature.title ?? "Title")
                        .font(.nunitoBold(20))
                    Text(feature.description ?? "This summary, which briefly sets out your rights and obligations in relation to administration charges")
                        .font(.nunitoSans(16))
                    
                    if let _ = feature.url {
                        HStack {
                            Spacer()
                            Button {
                                
                            } label: {
                                Text("Take me there")
                                    .font(.nunitoSemiBold(16))
                            }
                        }
                    }
                }
                .padding(.top, 20)
                .padding(.horizontal, 20)
                .padding(.bottom, 10)
                
                Spacer()
            }
        }
        .padding()
    }
}

struct WhatsNewSwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        let feature = NewFeatureModel(title: "New Feature", description: "Check out this mint new feature yo.", url: nil)
        let feature2 = NewFeatureModel(title: "New Feature", description: "Check out this mint new feature yo.", url: "")
        WhatsNewSwiftUIView(viewModel: WhatsNewViewModel(features: [feature, feature2], merchants: [207 ]))
    }
}
