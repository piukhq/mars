//
//  FeatureFlagsSwiftUIView.swift
//  binkapp
//
//  Created by Sean Williams on 18/06/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import SwiftUI

struct FeatureFlagsSwiftUIView: View {
    @ObservedObject private var themeManager = Current.themeManager
    private let features = Current.featureManager.features ?? []
        
    init() {
        UITableView.appearance().backgroundColor = .clear
    }
    
    var body: some View {
        List {
            Section {
                ForEach(features) { feature in
                    FeatureFlagCell(feature: feature)
                }
            }
            .listRowBackground(Color(themeManager.color(for: .walletCardBackground)))
        }
        .listStyle(InsetGroupedListStyle())
        .background(Color(themeManager.color(for: .insetGroupedTableBackground)))
        .ignoresSafeArea(.all, edges: .bottom)
        .navigationTitle("Feature Flags")
    }
}

struct FeatureFlagCell: View {
    private var feature: BetaFeature

    @State private var isEnabled: Bool
    
    init(feature: BetaFeature) {
        self.feature = feature
        _isEnabled = State(initialValue: feature.isEnabled)
    }
    
    var body: some View {
        Toggle(isOn: $isEnabled, label: {
            VStack(alignment: .leading, spacing: nil) {
                Text(feature.title ?? "")
                    .font(.custom(UIFont.linkTextButtonNormal.fontName, size: UIFont.linkTextButtonNormal.pointSize))
                Text(feature.description ?? "")
                    .font(.custom(UIFont.bodyTextSmall.fontName, size: UIFont.bodyTextSmall.pointSize))
                    .lineLimit(1)
            }
        })
        .toggleStyle(SwitchToggleStyle(tint: Color(.binkGradientBlueRight)))
        .onChange(of: isEnabled, perform: { enabled in
            Current.featureManager.toggle(feature, enabled: enabled)
        })
    }
}

struct FeatureFlagsSwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        FeatureFlagsSwiftUIView()
    }
}
