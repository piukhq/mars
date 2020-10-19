//
//  BarcodeViewModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import UIKit
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
    
    /// Code 39 barcodes draw at a fixed width [in the ZXing library](https://github.com/zxing/zxing/blob/723b65fe3dc65b88d26efa4c65e4217234a06ef0/core/src/main/java/com/google/zxing/oned/Code39Writer.java#L59).
    func preferredWidth(for length: Int, targetWidth: CGFloat) -> CGFloat {
        if self == .code39 {
            let baseWidth = CGFloat(24 + 1 + (13 * length))
            let codeWidth = baseWidth * ceil(targetWidth / baseWidth)
            return codeWidth
        } else {
            return 1
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
        guard let barcodeString = membershipCard.card?.barcode else { return nil }
        
        let writer = ZXMultiFormatWriter()
        let encodeHints = ZXEncodeHints()
        encodeHints.margin = 0
        
        
        let width = self.barcodeType == .code39 ? self.barcodeType.preferredWidth(for: barcodeString.count, targetWidth: size.width) : size.width
        let height = size.height
        var image: UIImage?
        
        let exception = tryBlock { [weak self] in
            guard let self = self else { return }
            
            let result = try? writer.encode(
                barcodeString, 
                format: self.barcodeType.zxingType,
                width: Int32(width),
                height: Int32(height),
                hints: encodeHints
            )
            
            guard let cgImage = ZXImage(matrix: result).cgimage else { return }
            
            // If the resulting image is larger than the destination, draw the CGImage in a fixed container
            if CGFloat(cgImage.width) > size.width {
                
                let renderer = UIGraphicsImageRenderer(size: size)

                let img = renderer.image { ctx in
                    ctx.cgContext.draw(cgImage, in: CGRect(origin: .zero, size: size))
                }

                image = img
            } else {
                image = UIImage(cgImage: cgImage)
            }
        }
        
        return exception == nil ? image : nil
    }
}
