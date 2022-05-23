//
//  VisionImageDetectionUtility.swift
//  binkapp
//
//  Created by Sean Williams on 22/10/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import UIKit
import Vision

enum PaymentCardNameRecognition {
    static let ignoreList: Set = [
        "monzo", "customer", "debit", "visa", "mastercard", "navy", "american", "express", "thru", "good", "authorized", "signature", "wells", "navy", "credit", "federal", "union", "bank", "valid", "validfrom", "validthru", "llc", "business", "netspend", "goodthru", "chase", "fargo", "hsbc", "usaa", "chaseo", "commerce", "last", "of", "lastdayof", "check", "card", "inc", "first", "member", "since", "american", "express", "republic", "bmo", "capital", "one", "capitalone", "platinum", "expiry", "date", "expiration", "cash", "back", "td", "access", "international", "interac", "nterac", "entreprise", "business", "md", "enterprise", "fifth", "third", "fifththird", "world", "rewards", "citi", "member", "cardmember", "cardholder", "valued", "since", "membersince", "cardmembersince", "cardholdersince", "freedom", "quicksilver", "penfed", "use", "this", "card", "is", "subject", "to", "the", "inc", "not", "transferable", "gto", "mgy", "sign", "exp", "end", "from"
    ]
    
    static func nonNameWordMatch(_ text: String) -> Bool {
        let lowerCase = text.lowercased()
        return ignoreList.contains(lowerCase)
    }
    
    static func onlyLettersAndSpaces(_ text: String) -> Bool {
        let lettersAndSpace = text.reduce(true) { acc, value in
            let capitalLetter = value >= "A" && value <= "Z"
            // We're only going to accept upper case names
            // let lowerCaseLetter = value >= "a" && value <= "z"
            let space = value == " "
            return acc && (capitalLetter || space)
        }
        
        return lettersAndSpace
    }
}

class VisionUtility {
    private let requestHandler = VNSequenceRequestHandler()

    // MARK: - Payment Card
    var pan: String?
    var expiryMonth: Int?
    var expiryYear: Int?
    var name: String?
    
    var ocrComplete: Bool {
        return pan != nil && expiryMonth != nil && expiryYear != nil && name != nil
    }
    
    func recognizePaymentCard(frame: CVImageBuffer, rectangle: VNRectangleObservation, completion: (PaymentCardCreateModel?) -> Void) {
        performTextRecognition(frame: frame, rectangle: rectangle) { observations in
            guard let observations = observations else { return }
            let recognizedTexts = observations.compactMap { observation in
                return observation.topCandidates(1).first
            }
            
            if pan == nil, let validatedPanText = recognizedTexts.first(where: { PaymentCardType.validate(fullPan: $0.string) }) {
                self.pan = validatedPanText.string
            }
            
            if expiryMonth == nil || expiryYear == nil, let (month, year) = self.extractExpiryDate(observations: observations) {
                self.expiryMonth = Int(month)
                self.expiryYear = Int("20\(year)")
            }
            
            for text in recognizedTexts {
                if text.confidence == 1, let name = self.likelyName(text: text.string) {
                    print("SW: NAME ----------------- \(name)")
                    self.name = name
                }
            }
            
            if ocrComplete {
                completion(PaymentCardCreateModel(fullPan: pan, nameOnCard: name, month: expiryMonth, year: expiryYear))
            } else {
                completion(nil)
            }
        }
    }
    
    func detectPaymentCard(frame: CVImageBuffer) -> VNRectangleObservation? {
        let rectangleDetectionRequest = VNDetectRectanglesRequest()
        let textDetectionRequest = VNDetectTextRectanglesRequest()
        
        try? self.requestHandler.perform([rectangleDetectionRequest, textDetectionRequest], on: frame)
        
        guard let rectangle = (rectangleDetectionRequest.results)?.first, let text = (textDetectionRequest.results)?.first, rectangle.boundingBox.contains(text.boundingBox) else {
            return nil
        }
        
        return rectangle
    }
    
    func trackPaymentCard(for observation: VNRectangleObservation, in frame: CVImageBuffer) -> VNRectangleObservation? {
        let request = VNTrackRectangleRequest(rectangleObservation: observation)
        request.trackingLevel = .fast
        
        try? self.requestHandler.perform([request], on: frame)
        
        guard let trackedRectangle = (request.results as? [VNRectangleObservation])?.first else { return nil }
        return trackedRectangle
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
            /// No text detected
            completion(nil)
            return
        }
        
        completion(observations)
    }
    
    private func extractExpiryDate(observations: [VNRecognizedTextObservation]) -> (String, String)? {
        for text in observations.flatMap({ $0.topCandidates(1) }) {
            if text.confidence == 1, let expiry = likelyExpiry(text.string) {
                return expiry
            }
        }
        return nil
    }
    
    private func likelyName(text: String) -> String? {
        let words = text.split(separator: " ").map { String($0) }
        let validWords = words.filter { !PaymentCardNameRecognition.nonNameWordMatch($0) && PaymentCardNameRecognition.onlyLettersAndSpaces($0) }
        let validWordCount = validWords.count >= 2
        return validWordCount ? validWords.joined(separator: " ") : nil
    }
    
    private func likelyExpiry(_ string: String) -> (String, String)? {
        guard let regex = try? NSRegularExpression(pattern: "^.*(0[1-9]|1[0-2])[./]([1-2][0-9])$") else {
            return nil
        }
        
        let result = regex.matches(in: string, range: NSRange(string.startIndex..., in: string))
        guard !result.isEmpty else { return nil }
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
