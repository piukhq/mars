//
//  ClearButton.swift
//  binkapp
//
//  Created by Sean Williams on 23/09/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import SwiftUI

public struct ClearButton: ViewModifier {
    @Binding var text: String
    @Binding var isEditing: Bool

    public init(text: Binding<String>, isEditing: Binding<Bool>) {
        self._text = text
        self._isEditing = isEditing
    }

    public func body(content: Content) -> some View {
        HStack {
            content
            Spacer()
            if !text.isEmpty && isEditing {
                Image(systemName: "multiply.circle.fill")
                    .foregroundColor(Color(Current.themeManager.color(for: .divider)))
                    .offset(x: -3)
                    .frame(width: 25.0)
                    .onTapGesture { self.text = "" }
            }
        }
    }
}
