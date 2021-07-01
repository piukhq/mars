//
//  AddCardView.swift
//  BinkWidgetExtension
//
//  Created by Sean Williams on 01/07/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import SwiftUI

struct AddCardView: View {
    let membershipCard: MembershipCardWidget

    var body: some View {
        Link(destination: membershipCard.url) {
            HStack(alignment: .center, spacing: 0) {
                Spacer()
                Image(systemName: "plus")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20.0, height: 36.0)
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(QuickLaunchConstants.walletCardInsets)
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(Color.gray, lineWidth: 1)
            )
            .background(
                RoundedRectangle(cornerRadius: 12.0, style: .continuous)
                    .foregroundColor(Color(.clear))
            )
        }
    }
}
