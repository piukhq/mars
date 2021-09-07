//
//  BinkButtonSwiftUIView.swift
//  binkapp
//
//  Created by Sean Williams on 07/09/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import SwiftUI

struct BinkGradientButtonSwiftUIView: View {
    var body: some View {
        Button("Continue") {
            print("Tapped")
        }
        .frame(width: UIScreen.main.bounds.width * 0.75, height: 52.0)
        .background(LinearGradient(gradient: Gradient(colors: [Color(.binkGradientBlueRight), Color(.binkGradientBlueLeft)]), startPoint: .leading, endPoint: .trailing))
        .cornerRadius(52 / 2)
        .foregroundColor(.white)
        .font(.custom(UIFont.buttonText.fontName, size: UIFont.buttonText.pointSize))
    }
}

//struct BinkButtonSwiftUIView_Previews: PreviewProvider {
//    static var previews: some View {
//        BinkGradientButtonSwiftUIView()
//    }
//}

struct BinkButtonsStackView: View {
    enum Constants {
        static let buttonHeight: CGFloat = 52.0
        static let buttonSpacing: CGFloat = 25.0
        static let height: CGFloat = buttonHeight + buttonSpacing
    }
    
    @ObservedObject private var themeManager = Current.themeManager
    var buttonCount: CGFloat = 1
    
    var body: some View {
        VStack {
            Spacer()
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color(themeManager.color(for: .viewBackground)), Color.clear]), startPoint: .bottom, endPoint: .top)
                    .padding(.top, 40)
                
                VStack(alignment: .center, spacing: Constants.buttonSpacing) {
                    Spacer(minLength: Constants.buttonSpacing)
                    BinkGradientButtonSwiftUIView()
//                    BinkGradientButtonSwiftUIView()
                    Spacer(minLength: BinkButtonsView.bottomSafePadding)
                }
            }
            .frame(width: UIScreen.main.bounds.width, height: BinkButtonsView.bottomSafePadding + (Constants.height * buttonCount), alignment: .center)
        }
        .background(Color.clear)
    }
}

struct BinkButtonStackView_Previews: PreviewProvider {
    static var previews: some View {
        BinkButtonsStackView()
    }
}
