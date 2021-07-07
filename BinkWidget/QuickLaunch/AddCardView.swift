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
    
    enum Constants {
        static let addCardImageSize = CGSize(width: 20, height: 36)
        static let cornerRadius: CGFloat = 12
        static let lineWidth: CGFloat = 1
    }

    var body: some View {
        Link(destination: membershipCard.url) {
            HStack(alignment: .center, spacing: 0) {
                Spacer()
                Image(systemName: "plus")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: Constants.addCardImageSize.width, height: Constants.addCardImageSize.height)
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(WalletCardView.Constants.insets)
            .overlay(
                RoundedRectangle(cornerRadius: Constants.cornerRadius, style: .continuous)
                    .stroke(Color.gray, lineWidth: Constants.lineWidth)
            )
        }
    }
}
