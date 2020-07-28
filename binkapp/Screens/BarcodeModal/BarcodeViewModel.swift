//
//  BarcodeViewModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import UIKit
import BarcodeGenerator
import ZXingObjC

enum BarcodeUse {
    case loyaltyCard
    case coupon
}

enum BarcodeType: Int {
    case code128
    case qr
    case aztec
    case pdf417
    case ean13
    case dataMatrix
    case itf
    case code39
    
    var zxingType: ZXBarcodeFormat {
        switch self {
        case .code128:
            return kBarcodeFormatCode128
        case .qr:
            return kBarcodeFormatQRCode
        case .aztec:
            return kBarcodeFormatAztec
        case .pdf417:
            return kBarcodeFormatPDF417
        case .ean13:
            return kBarcodeFormatEan13
        case .dataMatrix:
            return kBarcodeFormatDataMatrix
        case .itf:
            return kBarcodeFormatITF
        case .code39:
            return kBarcodeFormatCode39
        }
    }
}

class BarcodeViewModel {
    private let membershipCard: CD_MembershipCard
    
    var title: String {
        return membershipCard.membershipPlan?.account?.companyName ?? ""
    }
    
    var isBarcodeAvailable: Bool {
        return ((membershipCard.card?.barcode) != nil)
    }
    
    var isCardNumberAvailable: Bool {
        return cardNumber != nil
    }
    
    var cardNumber: String? {
        return membershipCard.card?.membershipId
    }
    
    var barcodeNumber: String {
        return membershipCard.card?.barcode ?? ""
    }
    
    var barcodeUse: BarcodeUse {
        return .loyaltyCard
    }
    
    var barcodeType: BarcodeType {
        guard let barcodeType = membershipCard.card?.barcodeType?.intValue else {
            return .code128
        }
        return BarcodeType(rawValue: barcodeType) ?? .code128
    }

    init(membershipCard: CD_MembershipCard) {
        self.membershipCard = membershipCard
    }
    
    func barcodeImage(withSize size: CGSize) -> UIImage? {
        guard let barcodeString = membershipCard.card?.barcode else {
            fatalError("Card has no barcode. We should never get here.")
        }
        
        let writer = ZXMultiFormatWriter()
        let encodeHints = ZXEncodeHints()
        encodeHints.margin = 0
        let result = try? writer.encode(barcodeString, format: barcodeType.zxingType, width: Int32(size.width), height: Int32(size.height), hints: encodeHints)
        guard let cgImage = ZXImage(matrix: result).cgimage else { return nil }
        return UIImage(cgImage: cgImage)
    }
}
