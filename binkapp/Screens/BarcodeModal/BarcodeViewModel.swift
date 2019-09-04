//
//  BarcodeViewModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import UIKit
import EANBarcodeGenerator

enum BarcodeType {
    case loyaltyCard
    case coupon
}

enum BarcodeName: String {
    case barcode128 = "CICode128BarcodeGenerator"
    case qrCode = "CIQRCodeGenerator"
    case aztec = "CIAztecCodeGenerator"
    case pdf417 = "CIPDF417BarcodeGenerator"
    case ean13 = "CIEANBarcodeGenerator"
    case dataMatrix = "CIDataMatrixCodeDescriptor"
//    case itf = ""
//    case code39 = ""
}

class BarcodeViewModel {
    private let membershipPlan: MembershipPlanModel
    private let membershipCard: MembershipCardModel
    
    init(membershipPlan: MembershipPlanModel, membershipCard: MembershipCardModel) {
        self.membershipPlan = membershipPlan
        self.membershipCard = membershipCard
    }
    
    func getTitle() -> String {
        return membershipPlan.account?.companyName ?? ""
    }
    
    func getCardNumber() -> String {
        return membershipCard.card?.barcode ?? ""
    }
    
    func getBarcodeType() -> BarcodeType {
        return .loyaltyCard
    }
    
    private func getBarcodeName() -> String {
        switch membershipCard.card?.barcodeType {
        case 0: return BarcodeName.barcode128.rawValue
        case 1: return BarcodeName.qrCode.rawValue
        case 2: return BarcodeName.aztec.rawValue
        case 3: return BarcodeName.pdf417.rawValue
        case 4:
            CIEANBarcodeGenerator.register()
            return BarcodeName.ean13.rawValue
        case 5: return BarcodeName.dataMatrix.rawValue
        case 6: return ""
        case 7: return ""
        default: return ""
        }
    }
    
    func generateBarcodeImage() -> UIImage? {
        guard let barcodeString = membershipCard.card?.barcode else { return nil }
        
        let data = barcodeString.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: getBarcodeName()) {
            filter.setDefaults()
            //Margin
            filter.setValue(7.00, forKey: "inputQuietSpace")
            filter.setValue(data, forKey: "inputMessage")
            //Scaling
            let transform = CGAffineTransform(scaleX: 3, y: 3)
            
            if let output = filter.outputImage?.transformed(by: transform) {
                let context: CIContext = CIContext.init(options: nil)
                let cgImage: CGImage = context.createCGImage(output, from: output.extent)!
                let rawImage: UIImage = UIImage.init(cgImage: cgImage)
                let cropZone = CGRect(x: 0, y: 0, width: Int(rawImage.size.width), height: Int(rawImage.size.height))
                let cWidth: size_t  = size_t(cropZone.size.width)
                let cHeight: size_t  = size_t(cropZone.size.height)
                let bitsPerComponent: size_t = cgImage.bitsPerComponent
                //THE OPERATIONS ORDER COULD BE FLIPPED, ALTHOUGH, IT DOESN'T AFFECT THE RESULT
                let bytesPerRow = (cgImage.bytesPerRow) / (cgImage.width  * cWidth)
                
                let context2: CGContext = CGContext(data: nil, width: cWidth, height: cHeight, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: cgImage.bitmapInfo.rawValue)!
                
                context2.draw(cgImage, in: cropZone)
                
                let result: CGImage  = context2.makeImage()!
                let finalImage = UIImage(cgImage: result)
                
                return finalImage
                
            }
        }
        
        return nil
    }
}
