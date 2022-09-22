//
//  VisionUtility.swift
//  binkapp
//
//  Created by Sean Williams on 22/10/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import Combine
import UIKit
import Vision

class VisionUtility: ObservableObject {
    private let requestHandler = VNSequenceRequestHandler()
    
    // MARK: - Loyalty Card
    
    // var barcode: String?
    // var membershipPlan: CD_MembershipPlan?
    var barcodeDetected = false

    // MARK: - Still image
     
    func detectBarcode(ciImage: CIImage? = nil, completion: @escaping (String?) -> Void ) {
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
                    guard !self.barcodeDetected else { return }
                    self.barcodeDetected = true
                    completion(stringValue)
                }
            }
            return request
        }
        
        detectBarcodeString(from: ciImage) { barcode in
            guard !self.barcodeDetected else { return }
            self.barcodeDetected = true
            completion(barcode)
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

     private func detectBarcodeString(from ciImage: CIImage?, completion: @escaping (String?) -> Void ) {
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

             for text in recognizedTexts {
                 let formattedText = text.string.replacingOccurrences(of: " ", with: "")
                 Current.wallet.identifyMembershipPlanForBarcode(formattedText) { plan in
 //                    guard !self.barcodeDetected else { return }
                     guard plan != nil else { return }
 //                        self.membershipPlan = plan
 //                        self.barcode = formattedText
 //                        self.barcodeDetected = true
 //
                         completion(formattedText)
 //                    }
                 }
             }
         }
     }
 }
