//
//  WalletCardView.swift
//  BinkWidgetExtension
//
//  Created by Sean Williams on 01/07/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import SwiftUI

enum QuickLaunchConstants {
    static let walletCardInsets = EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12)
}

struct WalletCardView: View {
    let membershipCard: MembershipCardWidget
    
    var body: some View {
        Link(destination: membershipCard.url) {
            HStack(alignment: .center, spacing: 0) {
                if let imageData = membershipCard.imageData, let uiImage = UIImage(data: imageData) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .frame(width: 39, height: 39, alignment: .center)
                            .foregroundColor(.white)
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 36.0, height: 36.0)
                            .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                    }.shadow(color: Color(.displayP3, white: 2, opacity: 0.5), radius: 2, x: 1.0, y: 1.0)
                    Spacer()
                } else {
                    RoundedRectangle(cornerRadius: 5)
                        .frame(width: 36, height: 36, alignment: .center)
                        .foregroundColor(Color(UIColor(hexString: "#FFFFFF", alpha: 0.5)))
                    Spacer()
                }
            }
            .padding(QuickLaunchConstants.walletCardInsets)
            .background(
                RoundedRectangle(cornerRadius: 12.0, style: .continuous)
                    .foregroundColor(Color(UIColor(hexString: membershipCard.backgroundColor ?? "#009190")))
            )
        }
    }
}
