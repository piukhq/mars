//
//  BarcodeViewModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import UIKit
import BarcodeGenerator

enum BarcodeType {
    case loyaltyCard
    case coupon
}

class BarcodeViewModel {
    private let membershipPlan: MembershipPlanModel
    private let membershipCard: MembershipCardModel
    
    var title: String {
        return membershipPlan.account?.companyName ?? ""
    }

    init(membershipPlan: MembershipPlanModel, membershipCard: MembershipCardModel) {
        self.membershipPlan = membershipPlan
        self.membershipCard = membershipCard
    }
    
    func getCardNumber() -> String {
        return membershipCard.card?.barcode ?? ""
    }
    
    func getBarcodeType() -> BarcodeType {
        return .loyaltyCard
    }
    
    private func getBarcodeType() -> BINKBarcodeType {
        switch membershipCard.card?.barcodeType {
        case 0: return BINKBarcodeType.code128
        case 1: return BINKBarcodeType.QR
        case 2: return BINKBarcodeType.aztec
        case 3: return BINKBarcodeType.PDF417
        case 4: return BINKBarcodeType.EAN13
        case 5: return BINKBarcodeType.dataMatrix
        case 6: return BINKBarcodeType.ITF
        case 7: return BINKBarcodeType.code39
        default: return .code128
        }
    }
    
    func generateBarcodeImage(for imageView: UIImageView) {
        guard let barcodeString = membershipCard.card?.barcode else { return }
        
        let image = BINKBarcodeGenerator.generateBarcode(
            withContents: barcodeString,
            of: getBarcodeType(),
            in: imageView.bounds.size
        )
                
        imageView.image = image
    }
}
