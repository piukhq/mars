//
//  QuickLaunchWidgetGridSpacerView.swift
//  BinkWidgetExtension
//
//  Created by Sean Williams on 01/07/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import SwiftUI

struct QuickLaunchWidgetGridSpacerView: View {
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            Spacer().frame(width: AddCardView.Constants.addCardImageSize.width, height: AddCardView.Constants.addCardImageSize.height, alignment: .center)
        }
        .padding(WalletCardView.Constants.insets)
        .background(
            RoundedRectangle(cornerRadius: WalletCardView.Constants.cornerRadius)
                .foregroundColor(Color(.clear))
        )
    }
}
