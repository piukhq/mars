//
//  NewFeatureView.swift
//  binkapp
//
//  Created by Sean Williams on 02/03/2023.
//  Copyright © 2023 Bink. All rights reserved.
//

import SwiftUI

struct NewFeatureView: View {
    var feature: NewFeatureModel
    let viewModel = NewFeatureViewModel()
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .frame(maxHeight: 150)
                .foregroundColor(Color(Current.themeManager.color(for: .walletCardBackground)))
            HStack {
                VStack(alignment: .leading, spacing: 10) {
                    Text(feature.title ?? "Title")
                        .font(.nunitoBold(18))
                        .foregroundColor(Color(Current.themeManager.color(for: .text)))
                    Text(feature.description ?? "This summary, which briefly sets out your rights and obligations in relation to administration charges")
                        .font(.nunitoSans(14))
                        .foregroundColor(Color(Current.themeManager.color(for: .text)))
                    
                    if let screen = feature.screen {
                        HStack {
                            Spacer()
                            Button {
                                viewModel.navigate(to: Screen(rawValue: screen))
                            } label: {
                                Text("Take me there")
                                    .font(.nunitoSemiBold(14))
                                    .foregroundColor(Color(Current.themeManager.color(for: .text)))
                            }
                        }
                    }
                }
                .padding(20)
                
                Spacer()
            }
        }
        .padding()
    }
}

struct NewFeatureView_Previews: PreviewProvider {
    static var previews: some View {
        NewFeatureView(feature: NewFeatureModel(id: nil, title: "Updates", description: "Great stuff here", screen: 2))
    }
}
