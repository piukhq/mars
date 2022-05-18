//
//  VisionImageDetectionUtility.swift
//  binkapp
//
//  Created by Sean Williams on 22/10/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import UIKit
import Vision

class VisionImageDetectionUtility {
    private let requestHandler = VNSequenceRequestHandler()
    
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
    
    func processImage(_ image: UIImage) {
        guard let cgImage = image.cgImage else { return }
        
        let ocrRequest = VNRecognizeTextRequest { request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            
            for observation in observations {
                guard let topCandidate = observation.topCandidates(1).first else { return }
                print("SW: \(topCandidate.string)")
            }
        }
        
        ocrRequest.recognitionLevel = .accurate
//        ocrRequest.recognitionLanguages = ["en-US", "en-GB"]
        ocrRequest.usesLanguageCorrection = false
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try requestHandler.perform([ocrRequest])
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func detectPaymentCard(frame: CVImageBuffer) -> VNRectangleObservation? {
        let rectangleDetectionRequest = VNDetectRectanglesRequest()
        let paymentCardAspectRatio: Float = 85.60 / 53.98
        rectangleDetectionRequest.minimumAspectRatio = paymentCardAspectRatio * 0.95
        rectangleDetectionRequest.maximumAspectRatio = paymentCardAspectRatio * 0.10
        
        let textDetectionRequest = VNDetectTextRectanglesRequest()
        
        try? self.requestHandler.perform([rectangleDetectionRequest], on: frame)
        
        guard let rectangle = rectangleDetectionRequest.results?.first,
              let text = textDetectionRequest.results?.first,
              rectangle.boundingBox.contains(text.boundingBox) else {
            // no credit card rectangle detected
            return nil
        }
        
        return rectangle
    }
}
