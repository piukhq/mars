//
//  CardInformationView.swift
//  binkapp
//
//  Created by Sean Williams on 09/09/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import SwiftUI

struct CardInformationView: View {
    var informationRows: [CardDetailInformationRow]
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<informationRows.count) { index in
                CardDetailInfoTableView(rowData: informationRows[index], showSeparator: showSeparator(index: index))
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(Color(Current.themeManager.color(for: .divider)))
            }
        }
        .background(Color(Current.themeManager.color(for: .viewBackground)))
        .padding(.horizontal, 30)
//        .padding(.vertical, 10)
    }
    
    private func showSeparator(index: Int) -> Bool {
        return index == (informationRows.count - 1) ? false : true
    }
}

struct CardInformationView_Previews: PreviewProvider {
    static private var paymentRows = WalletCardDetailInformationRowFactory().makePaymentInformationRows(for: .active)
    static var previews: some View {
        VStack {
            CardInformationView(informationRows: paymentRows)
        }
        .padding()
    }
}

struct CardDetailInfoTableView: View {
    private enum Constants {
        static let rowHeight: CGFloat = 70
        static let separatorHeight: CGFloat = 1.0
        static let actionRequiredIndicatorHeight: CGFloat = 10
        static let padding: CGFloat = 20.0
    }
    
    var rowData: CardDetailInformationRow
    var showSeparator: Bool
    
    var body: some View {
        Button {
            rowData.action()
        } label: {
            VStack {
                HStack {
                    VStack(alignment: .leading) {
                        Text(rowData.type.title)
                            .foregroundColor(Color(Current.themeManager.color(for: .text)))
                            .uiFont(.subtitle)
                        if let subtitle = rowData.type.subtitle {
                            Text(subtitle)
                                .uiFont(.bodyTextLarge)
                                .foregroundColor(Color(Current.themeManager.color(for: .text)))
                        }
                    }
                    .frame(height: Constants.rowHeight)
                    
                    Spacer()
                    
                    Image(uiImage: Asset.iconsChevronRight.image)
                        .foregroundColor(Color(Current.themeManager.color(for: .text)))
                }
                .padding(.vertical, 10)
                
//                if showSeparator {
//                    Rectangle()
//                        .frame(height: Constants.separatorHeight)
//                        .foregroundColor(Color(Current.themeManager.color(for: .divider)))
////                        .padding(.bottom, 10)
//                }
            }
//            .background(Color.purple)

//            .background(Color(Current.themeManager.color(for: .viewBackground)))
        }
    }
}
