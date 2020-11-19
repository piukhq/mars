//
//  BarcodeViewModelMock.swift
//  binkapp
//
//  Created by Sean Williams on 16/11/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import Foundation
import UIKit
import ZXingObjC

class BarcodeViewModelMock {
    var membershipCard: MembershipCardModel
    var membershipPlan: MembershipPlanModel
    
    var title: String {
        return membershipPlan.account?.companyName ?? ""
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
    
    var barcodeUse: BarcodeUse = .loyaltyCard
    
    var barcodeType: BarcodeType {
        guard let barcodeType = BarcodeType(rawValue: membershipCard.card?.barcodeType ?? 0) else {
            return .code128
        }
        return barcodeType
    }

    init(membershipCard: MembershipCardModel, membershipPlan: MembershipPlanModel) {
        self.membershipCard = membershipCard
        self.membershipPlan = membershipPlan
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
            
            let result = try? writer.encode(barcodeString, format: self.barcodeType.zxingType, width: Int32(width), height: Int32(height), hints: encodeHints)
            
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
