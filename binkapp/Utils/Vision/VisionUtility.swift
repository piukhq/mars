//
//  VisionImageDetectionUtility.swift
//  binkapp
//
//  Created by Sean Williams on 22/10/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import Combine
import UIKit
import Vision

class VisionUtility: ObservableObject {
    enum VisionError: Error {
        case barcodeDetionFailure
    }
    
    private let requestHandler = VNSequenceRequestHandler()

    // MARK: - Payment Card
    var pan: String?
    var expiryMonth: Int?
    var expiryYear: Int?
    var name: String?
    
    var paymentCard: PaymentCardCreateModel {
        return PaymentCardCreateModel(fullPan: pan, nameOnCard: name, month: expiryMonth, year: expiryYear)
    }
    
    var ocrComplete: Bool {
        return pan != nil && expiryMonth != nil && expiryYear != nil && name != nil
    }
    
    let subject = PassthroughSubject<PaymentCardCreateModel, Error>()
    
    func recognizePaymentCard(in image: CIImage) {
        performTextRecognition(in: image) { [weak self] observations in
            guard let observations = observations else { return }
            guard let self = self else { return }
            let recognizedTexts = observations.compactMap { observation in
                return observation.topCandidates(1).first
            }
            
            if pan == nil, let validatedPanText = recognizedTexts.first(where: { PaymentCardType.validate(fullPan: $0.string) }) {
                self.pan = validatedPanText.string
                self.scheduleTimer()
                self.subject.send(PaymentCardCreateModel(fullPan: self.pan, nameOnCard: self.name, month: self.expiryMonth, year: self.expiryYear))
            }
            
            if expiryMonth == nil || expiryYear == nil, let (month, year) = self.extractExpiryDate(observations: observations) {
                self.expiryMonth = Int(month)
                self.expiryYear = Int("20\(year)")
                self.subject.send(PaymentCardCreateModel(fullPan: self.pan, nameOnCard: self.name, month: self.expiryMonth, year: self.expiryYear))
            }
            
            for text in recognizedTexts {
                if text.confidence == 1, let name = self.likelyName(text: text.string) {
                    self.name = name
                    self.subject.send(PaymentCardCreateModel(fullPan: self.pan, nameOnCard: self.name, month: self.expiryMonth, year: self.expiryYear))
                }
            }
            
            if ocrComplete {
                self.subject.send(completion: .finished)
            }
        }
    }
    
    private func scheduleTimer() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            guard let self = self else { return }
            self.subject.send(completion: .finished)
        }
    }
    
    private func performTextRecognition(in image: CIImage, completion: ([VNRecognizedTextObservation]?) -> Void) {
        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = false
        
        let stillImageRequestHandler = VNImageRequestHandler(ciImage: image, options: [:])
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
                guard let expiryMonth = Int(expiry.0) else { return nil }
                guard let expiryYear = Int("20" + expiry.1) else { return nil }
                guard let date = Date.makeDate(year: expiryYear, month: expiryMonth, day: 01, hr: 12, min: 00, sec: 00) else { return nil }

                if date.monthHasNotExpired {
                    return expiry
                } else {
                    return nil
                }
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
    
    
    // MARK: - Barcode detection
    
    func detectBarcode(ciImage: CIImage? = nil, completion: @escaping (String?) -> Void) {
        var vnBarcodeDetectionRequest: VNDetectBarcodesRequest {
            let request = VNDetectBarcodesRequest { request, error in
                guard error == nil else {
                    completion(nil)
                    return
                }
                
                guard let observations = request.results as? [VNBarcodeObservation], let stringValue = observations.first?.payloadStringValue else {
                    completion(nil)
                    return
                }
                
                DispatchQueue.main.async {
                    completion(stringValue)
                }
            }
            return request
        }
        
        // Detect barcode
        var requestHandler: VNImageRequestHandler?
        if let ciImage = ciImage {
            requestHandler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        }
        
        let vnRequests = [vnBarcodeDetectionRequest]
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try requestHandler?.perform(vnRequests)
            } catch {
                completion(nil)
            }
        }
    }
    
    func detectBarcodeString(from ciImage: CIImage?, completion: @escaping (String?) -> Void) {
        guard let ciImage = ciImage else { return }

        let vnTextTextRecognitionRequest = VNRecognizeTextRequest()
        vnTextTextRecognitionRequest.recognitionLevel = .accurate
        vnTextTextRecognitionRequest.usesLanguageCorrection = false
        
        let stillImageRequestHandler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        try? stillImageRequestHandler.perform([vnTextTextRecognitionRequest])
        
        if let observations = vnTextTextRecognitionRequest.results, !observations.isEmpty {
            let recognizedTexts = observations.compactMap { observation in
                return observation.topCandidates(1).first
            }
            
            for (i, text) in recognizedTexts.enumerated() {
                let formattedText = text.string.replacingOccurrences(of: " ", with: "")
                Current.wallet.identifyMembershipPlanForBarcode(formattedText) { plan in
                    guard plan != nil else {
                        if i == (recognizedTexts.count - 1) {
                            completion(nil)
                        }
                        return
                    }
                    completion(formattedText)
                }
            }
        } else {
            completion(nil)
        }
    }
    
    
    // MARK: - Errors
    
    func showError(barcodeDetected: Bool, membershipPlan: CD_MembershipPlan? = nil) {
        let captureSource = BarcodeCaptureSource.photoLibrary(membershipPlan)
        let alert = ViewControllerFactory.makeOkAlertViewController(title: L10n.errorTitle, message: barcodeDetected ? captureSource.errorMessage : L10n.loyaltyScannerFailedToDetectBarcode)
        let navigationRequest = AlertNavigationRequest(alertController: alert)
        Current.navigate.to(navigationRequest)
    }
}
