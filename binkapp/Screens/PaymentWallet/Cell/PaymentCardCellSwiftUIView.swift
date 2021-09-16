//
//  PaymentCardCellSwiftUIView.swift
//  binkapp
//
//  Created by Sean Williams on 16/09/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import SwiftUI

struct PaymentCardCellSwiftUIView: UIViewRepresentable {
    @Binding var paymentCard: PaymentCardCreateModel?
    
    func makeUIView(context: Context) -> PaymentCardCollectionViewCell {
        let cell: PaymentCardCollectionViewCell = .fromNib()
        guard let paymentCard = paymentCard else { return cell }
        cell.configureWithAddViewModel(paymentCard)
        return cell
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        guard let paymentCard = paymentCard else { return }
        uiView.configureWithAddViewModel(paymentCard)
    }
}
