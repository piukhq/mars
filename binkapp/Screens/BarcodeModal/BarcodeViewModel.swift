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
    //TO DO: CHANGE VARIABLE NAME
    let string = "1234 5432 1242"
    let title = "Harvey Nichols"
    
    func getTitle() -> String {
        return title
    }
    
    func getCardNumber() -> String {
        return string
    }
    
    func getBarcodeType() -> BarcodeType {
        return .loyaltyCard
    }
    
    func generateBarcodeImage() -> UIImage? {
        
        //TODO: Use framework with the code below but we need to use the correct barcode type per membership_plan
        
//        let image = BINKBarcodeGenerator.generateBarcode(
//            withContents: string,
//            of: .QR,
//            in: CGSize(width: 350, height: 175)
//        )
//
//        return image
        
        let data = string.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CICode128BarcodeGenerator") {
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
