//
//  BinkButtonSwiftUIView.swift
//  binkapp
//
//  Created by Sean Williams on 07/09/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import SwiftUI

struct BinkGradientButtonSwiftUIView: View, Identifiable {
    @ObservedObject private var themeManager = Current.themeManager

    var id = UUID()
    var title: String
    @State var enabled = true
    
    var body: some View {
        Button(title) {
            print("Tapped")
        }
        .frame(width: UIScreen.main.bounds.width * 0.75, height: 52.0)
        .background(
            ZStack {
                Color(themeManager.color(for: .viewBackground))
                LinearGradient(gradient: Gradient(colors: [Color(.binkGradientBlueRight), Color(.binkGradientBlueLeft)]), startPoint: .leading, endPoint: .trailing)
                    .opacity(enabled ? 1.0 : 0.5)
            })
        .cornerRadius(52 / 2)
        .foregroundColor(enabled ? .white : .white.opacity(0.5))
        .font(.custom(UIFont.buttonText.fontName, size: UIFont.buttonText.pointSize))
        .shadow(color: .black.opacity(0.2), radius: 10, x: 3.0, y: 8.0)
        .disabled(!enabled)
    }
}

struct BinkButtonsStackView: View {
    enum Constants {
        static let buttonHeight: CGFloat = 52.0
        static let buttonSpacing: CGFloat = 25.0
        static let height: CGFloat = buttonHeight + buttonSpacing
    }
    
    @ObservedObject private var themeManager = Current.themeManager
    var buttons: [BinkGradientButtonSwiftUIView]
    
    var body: some View {
        VStack {
            Spacer()
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color(themeManager.color(for: .viewBackground)), .white.opacity(0.01)]), startPoint: .bottom, endPoint: .top)
                    .padding(.top, 20)
                
                VStack(alignment: .center, spacing: Constants.buttonSpacing) {
                    Spacer(minLength: Constants.buttonSpacing)
                    ForEach(buttons) { button in
                        button
                    }
                    Spacer(minLength: BinkButtonsView.bottomSafePadding)
                }
            }
            .frame(width: UIScreen.main.bounds.width, height: BinkButtonsView.bottomSafePadding + (Constants.height * CGFloat(buttons.count)), alignment: .center)
        }
        .background(Color.clear)
    }
}

struct BinkButtonStackView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ZStack {
                Rectangle()
                    .foregroundColor(Color(UIColor.grey10))
                BinkButtonsStackView(buttons: [BinkGradientButtonSwiftUIView(title: "Bello", enabled: false), BinkGradientButtonSwiftUIView(title: "Continue", enabled: true)])
            }
        }
    }
}
