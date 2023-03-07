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
                .foregroundColor(viewModel.backgroundColor)
            HStack {
                VStack(alignment: .leading, spacing: 10) {
                    Text(feature.title ?? "Title")
                        .font(.nunitoBold(18))
                        .foregroundColor(viewModel.textColor)
                    Text(feature.description ?? "This summary, which briefly sets out your rights and obligations in relation to administration charges")
                        .font(.nunitoSans(14))
                        .foregroundColor(viewModel.textColor)
                    
                    if let screen = feature.screen {
                        HStack {
                            Spacer()
                            Button {
                                viewModel.navigate(to: Screen(rawValue: screen))
                            } label: {
                                Text("Take me there")
                                    .font(.nunitoSemiBold(14))
                                    .foregroundColor(viewModel.textColor)
                            }
                        }
                    }
                }
                .padding(.vertical, 20)
                
                Spacer()
            }
        }
    }
}

struct NewFeatureView_Previews: PreviewProvider {
    static var previews: some View {
        NewFeatureView(feature: NewFeatureModel(id: nil, title: "Updates", description: "Great stuff here", screen: 2))
    }
}
