//
//  VisionImageDetectionUtility.swift
//  binkapp
//
//  Created by Sean Williams on 22/10/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import UIKit
import Vision

class VisionUtility {
    // MARK: - Payment Card
    var pan: String?
    var expiryMonth: Int?
    var expiryYear: Int?
    
    var ocrComplete: Bool {
        return pan != nil && expiryMonth != nil && expiryYear != nil
    }
    
    func recognizePaymentCard(frame: CVImageBuffer, rectangle: VNRectangleObservation, completion: (PaymentCardCreateModel?) -> Void) {
        performTextRecognition(frame: frame, rectangle: rectangle) { observations in
            guard let observations = observations else { return }
            
            if pan == nil, let paymentCard = self.extractPaymentCardNumber(texts: observations) {
                self.pan = paymentCard
            }
            
            if expiryMonth == nil || expiryYear == nil, let (month, year) = self.extractExpiryDate(observations: observations) {
                print("Expiry: - \(month + year)")
                self.expiryMonth = Int(month)
                self.expiryYear = Int(year)
            }
            
            if ocrComplete {
                completion(PaymentCardCreateModel(fullPan: pan, nameOnCard: nil, month: expiryMonth, year: expiryYear))
            } else {
                completion(nil)
            }
        }
    }
    
    private func performTextRecognition(frame: CVImageBuffer, rectangle: VNRectangleObservation, completion: ([VNRecognizedTextObservation]?) -> Void) {
        let cardPositionInImage = VNImageRectForNormalizedRect(rectangle.boundingBox, CVPixelBufferGetWidth(frame), CVPixelBufferGetHeight(frame))
        let ciImage = CIImage(cvImageBuffer: frame)
        let croppedImage = ciImage.cropped(to: cardPositionInImage)
        
        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = false
        
        let stillImageRequestHandler = VNImageRequestHandler(ciImage: croppedImage, options: [:])
        try? stillImageRequestHandler.perform([request])
        
        guard let observations = request.results, !observations.isEmpty else {
            // no text detected
            completion(nil)
            return
        }
        
        completion(observations)
    }
    
    private func extractPaymentCardNumber(texts: [VNRecognizedTextObservation]) -> String? {
        let recognizedText = texts.compactMap { observation in
            return observation.topCandidates(1).first?.string
        }
        
//        let potentialPANs = recognizedText.map { $0.trimmingCharacters(in: .whitespaces) }
        let PAN = recognizedText.first(where: { ["3", "4", "5", "6"].contains($0.first) })
        let formattedPAN = PAN?.replacingOccurrences(of: " ", with: "")
        
        if luhnCheck(formattedPAN ?? "") {
            return formattedPAN
        } else {
            return nil
        }
    }
    
//    func parseResults(for recognizedText: [String]) -> String? {
//        let creditCardNumber = recognizedText.first(where: { $0.count > 14 && ["4", "5", "3", "6"].contains($0.first) })
//        return creditCardNumber
//    }
    
    private func extractExpiryDate(observations: [VNRecognizedTextObservation]) -> (String, String)? {
        for text in observations.flatMap( { $0.topCandidates(1) }) {
            if let expiry = likelyExpiry(text.string) {
                return expiry
            }
        }
        return nil
    }
    
    private func luhnCheck(_ digits: String) -> Bool {
        guard digits.count == 16, CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: digits)) else {
            return false
        }
        var digits = digits
        let checksum = digits.removeLast()
        let sum = digits.reversed()
            .enumerated()
            .map({ (index, element) -> Int in
                if (index % 2) == 0 {
                   let doubled = Int(String(element))! * 2
                   return doubled > 9
                       ? Int(String(String(doubled).first!))! + Int(String(String(doubled).last!))!
                       : doubled
                } else {
                    return Int(String(element))!
                }
            })
            .reduce(0, { (res, next) in res + next })
        let checkDigitCalc = (sum * 9) % 10
        return Int(String(checksum))! == checkDigitCalc
    }
    
    private func likelyExpiry(_ string: String) -> (String, String)? {
        guard let regex = try? NSRegularExpression(pattern: "^.*(0[1-9]|1[0-2])[./]([1-2][0-9])$") else {
            return nil
        }
        
        let result = regex.matches(in: string, range: NSRange(string.startIndex..., in: string))
        
        if result.isEmpty {
            return nil
        }
        
        guard let nsrange1 = result.first?.range(at: 1), let range1 = Range(nsrange1, in: string) else { return nil }
        guard let nsrange2 = result.first?.range(at: 2), let range2 = Range(nsrange2, in: string) else { return nil }
        
        return (String(string[range1]), String(string[range2]))
    }
    
    
    // MARK: - Still image
    
    func createVisionRequest(image: UIImage, completion: @escaping (String?) -> Void ) {
        guard let cgImage = image.cgImage else { return }
        
        var vnBarcodeDetectionRequest: VNDetectBarcodesRequest {
            let request = VNDetectBarcodesRequest { request, error in
                guard error == nil else {
                    completion(nil)
                    return
                }
                
                guard let observations = request.results as? [VNBarcodeObservation], let stringValue = observations.first?.payloadStringValue else {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    completion(stringValue)
                }
            }
            return request
        }
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        let vnRequests = [vnBarcodeDetectionRequest]
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try requestHandler.perform(vnRequests)
            } catch {
                completion(nil)
            }
        }
    }
}
