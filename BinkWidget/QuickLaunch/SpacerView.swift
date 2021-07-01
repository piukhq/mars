//
//  SpacerView.swift
//  BinkWidgetExtension
//
//  Created by Sean Williams on 01/07/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import SwiftUI

struct SpacerView: View {
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            Spacer().frame(width: 20, height: 36, alignment: .center)
        }
        .padding(QuickLaunchConstants.walletCardInsets)
        .background(
            RoundedRectangle(cornerRadius: 12.0)
                .foregroundColor(Color(.clear))
        )
    }
}
