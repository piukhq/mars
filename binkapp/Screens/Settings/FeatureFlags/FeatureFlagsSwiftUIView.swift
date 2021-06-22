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
    private weak var delegate: FeatureFlagsViewControllerDelegate?
    
    @ObservedObject private var themeManager = Current.themeManager
    
    init(delegate: FeatureFlagsViewControllerDelegate? = nil) {
        self.delegate = delegate
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
        .onDisappear {
            delegate?.featureFlagsViewDidDismiss()
        }
    }
}

@available(iOS 14.0, *)
struct FeatureFlagCell: View {
    private var feature: Feature

    @State private var isEnabled: Bool
    
    init(feature: Feature) {
        self.feature = feature
        _isEnabled = State(initialValue: feature.isEnabled)
    }
    
    var body: some View {
        Toggle(isOn: $isEnabled, label: {
            VStack(alignment: .leading, spacing: nil) {
                Text(feature.title ?? "")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(feature.description ?? "")
                    .font(.footnote)
                    .fontWeight(.light)
                    .lineLimit(1)
            }
        })
        .toggleStyle(SwitchToggleStyle(tint: Color(.binkGradientBlueRight)))
        .onChange(of: isEnabled, perform: { enabled in
            Current.featureManager.toggle(feature, enabled: enabled)
        })
    }
}

@available(iOS 14.0, *)
struct FeatureFlagsSwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        FeatureFlagsSwiftUIView()
    }
}
