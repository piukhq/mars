//
//  ViewModifiers.swift
//  binkapp
//
//  Created by Sean Williams on 08/08/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import SwiftUI

struct UIKitFont: ViewModifier {
    var font: UIFont
    
    func body(content: Content) -> some View {
        content
            .font(.custom(font.fontName, fixedSize: font.pointSize))
    }
}

extension View {
    func uiFont(_ font: UIFont) -> some View {
        modifier(UIKitFont(font: font))
    }
}
