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
    
    init(delegate: FeatureFlagsViewControllerDelegate? = nil) {
        self.delegate = delegate
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(features) { feature in
                    FeatureFlagCell(feature: feature)
                }
                .navigationBarTitle("Feature Flags")
            }
            .listStyle(InsetGroupedListStyle())
        }.navigationTitle("Feature Flags")
        .onDisappear {
            delegate?.featureFlagsViewControllerDidDismiss()
        }
    }
}

@available(iOS 14.0, *)
struct FeatureFlagCell: View {
    var feature: Feature
    
    @State private var isEnabled: Bool
    
    init(feature: Feature) {
        self.feature = feature
        _isEnabled = State(initialValue: feature.isEnabled)
    }
    
    var body: some View {
        Toggle(isOn: $isEnabled, label: {
            VStack(alignment: .leading, spacing: nil, content: {
                Text(feature.title ?? "").font(.subheadline).fontWeight(.semibold)
                Text(feature.description ?? "").font(.footnote).fontWeight(.light).lineLimit(1)
            })
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
