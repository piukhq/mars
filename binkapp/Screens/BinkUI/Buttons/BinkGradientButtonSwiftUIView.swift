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
    var body: some View {
        VStack(alignment: .center, spacing: 25) {
            Spacer()
            BinkGradientButtonSwiftUIView()
            BinkGradientButtonSwiftUIView()
        }
    }
}

struct BinkButtonStackView_Previews: PreviewProvider {
    static var previews: some View {
        BinkButtonsStackView()
    }
}
