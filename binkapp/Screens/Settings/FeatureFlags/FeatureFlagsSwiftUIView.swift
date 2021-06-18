//
//  FeatureFlagsSwiftUIView.swift
//  binkapp
//
//  Created by Sean Williams on 18/06/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import SwiftUI

@available(iOS 14.0, *)
struct FeatureFlagsSwiftUIView: View {
    private let features = Current.featureManager.features ?? []
    
    var body: some View {
        NavigationView {
            List {
                ForEach(features) { feature in
                    FeatureFlagCell(feature: feature)
                }
                .navigationBarTitle("Feature Flags")
            }
        }.navigationTitle("Feature Flags")
    }
}

@available(iOS 14.0, *)
struct FeatureFlagCell: View {
    var feature: Feature
    
    var body: some View {
        Toggle(isOn: .constant(true), label: {
            VStack(alignment: .leading, spacing: nil, content: {
                Text(feature.title ?? "").font(.subheadline).fontWeight(.semibold)
                Text(feature.description ?? "").font(.footnote).fontWeight(.light).lineLimit(1)
            })
        })
        .toggleStyle(SwitchToggleStyle(tint: Color(.binkGradientBlueRight)))
    }
}

@available(iOS 14.0, *)
struct FeatureFlagsSwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        FeatureFlagsSwiftUIView()
    }
}
