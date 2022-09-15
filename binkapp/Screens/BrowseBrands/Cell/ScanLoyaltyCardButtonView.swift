//
//  ScanLoyaltyCardButtonView.swift
//  binkapp
//
//  Created by Sean Williams on 14/09/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import SwiftUI
import Lottie

struct ScanLoyaltyCardButtonView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10.0)
                .fill(LinearGradient(gradient: Gradient(colors: [Color(.binkGradientBlueRight), Color(.binkGradientBlueLeft)]), startPoint: .leading, endPoint: .trailing))
            HStack(spacing: 15) {
                Image(uiImage: Asset.scanQuick.image)
                    .resizable()
                    .frame(width: 50, height: 50)
                
                VStack(alignment: .leading) {
                    Text(L10n.scanButtonTitle)
                        .font(.nunitoExtraBold(20))
                        .foregroundColor(.white)
                    Text(L10n.scanButtonSubtitle)
                        .font(.nunitoSans(15))
                        .foregroundColor(.white)
                }
                
                Spacer()
            }
            .padding()
        }
        .frame(maxWidth: 1800, maxHeight: 88)
    }
}

struct ScanLoyaltyCardButtonView_Previews: PreviewProvider {
    static var previews: some View {
        ScanLoyaltyCardButtonView()
    }
}
