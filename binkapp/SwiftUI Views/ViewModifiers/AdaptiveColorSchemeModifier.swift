//
//  AdaptiveColorSchemeModifier.swift
//  binkapp
//
//  Created by Sean Williams on 29/09/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import SwiftUI

struct AdaptiveColorSchemeModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    
    func body(content: Content) -> some View {
        content.colorScheme(resolvedColor)
    }
    
    private var resolvedColor: ColorScheme {
        switch Current.themeManager.currentTheme.type {
        case .light:
            return .light
        case .dark:
            return .dark
        case .system:
            return colorScheme
        }
    }
}

extension View {
    func colorSchemeOverride() -> some View {
        modifier(AdaptiveColorSchemeModifier())
    }
}
