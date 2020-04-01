//
//  LoyaltyScannerViewController.swift
//  binkapp
//
//  Created by Nick Farrant on 26/03/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import UIKit
import AVFoundation
import Vision

class LoyaltyScannerViewController: UIViewController {

    var session = AVCaptureSession()
    var captureSchemeOutput: AVCaptureVideoDataOutput!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    var previewView = UIView()

    let schemeScanningQueue = DispatchQueue(label: "com.bink.wallet.scanning.loyalty.scheme.queue")

    var isLaunching = false
    var visionShouldProcessFrame = false
    var identificationApiShouldProcessFrame = false
    var isProcessingIdentificationApi = false
    var schemeIdentificationFailureCount = 0
    static let visionRateLimit = 0.2

    var rectOfInterest = CGRect.zero
    var viewFrame = CGRect.zero

    var schemeIdentifierSample: BINKLoyaltyScannerSchemeIdentifierSample!
    typealias LoyaltyScannerDetectionBlock = (VNRequest, Error) -> Void

    lazy var blurredView: UIVisualEffectView = {
        return UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
    }()

    lazy var guideImageView: UIImageView = {
        let image = UIImage(named: "scanner_guide")
        let imageView = UIImageView(image: image)
        return imageView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        view.addSubview(previewView)

        // BLUR AND MASK
        blurredView.frame = view.frame
        let maskLayer = CAShapeLayer()
        maskLayer.frame = view.frame
        maskLayer.fillColor = UIColor.black.cgColor
        // Setup rect of interest
        let inset: CGFloat = floor(view.frame.size.width * 0.112)
        let width = view.frame.size.width - (inset * 2)
        let viewFrameRatio: CGFloat = 12 / 18
        let height: CGFloat = floor(viewFrameRatio * width)
        let maskedAreaFrame = CGRect(x: inset, y: 100, width: width, height: height)
        rectOfInterest = maskedAreaFrame
        viewFrame = view.frame
        let maskedPath = UIBezierPath(roundedRect: rectOfInterest, cornerRadius: 8)
        maskedPath.append(UIBezierPath(rect: view.bounds))
        maskLayer.fillRule = .evenOdd
        maskLayer.path = maskedPath.cgPath
        blurredView.layer.mask = maskLayer
        view.addSubview(blurredView)

        guideImageView.frame = rectOfInterest.inset(by: UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15))
        view.addSubview(guideImageView)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startScanning()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopScanning()
    }

    private func startScanning() {
        session.sessionPreset = .high
        guard let backCamera = AVCaptureDevice.default(for: .video) else { return }
        guard let input = try? AVCaptureDeviceInput(device: backCamera) else { return }
        performCaptureChecksForDevice(backCamera)
        captureSchemeOutput = AVCaptureVideoDataOutput()

        if session.canAddInput(input) {
            session.addInput(input)
        }

        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
        guard let videoPreviewLayer = videoPreviewLayer else { return }
        videoPreviewLayer.videoGravity = .resizeAspect
        videoPreviewLayer.connection?.videoOrientation = .portrait

        previewView.layer.addSublayer(videoPreviewLayer)
        videoPreviewLayer.frame = view.frame

        if session.outputs.count == 0 {
            if session.canAddOutput(captureSchemeOutput) {
                session.addOutput(captureSchemeOutput)
                prepareSchemeScannerOutput()
            }
        }

        visionShouldProcessFrame = true
        isLaunching = false
        isProcessingIdentificationApi = false
        schemeIdentificationFailureCount = 0

        if !session.isRunning {
            session.startRunning()
        }
    }

    private func stopScanning() {
        schemeScanningQueue.async { [weak self] in
            self?.session.stopRunning()
            guard let outputs = self?.session.outputs else { return }
            for output in outputs {
                self?.session.removeOutput(output)
            }
        }
    }

    private func prepareSchemeScannerOutput() {
        captureSchemeOutput.alwaysDiscardsLateVideoFrames = true
        captureSchemeOutput.setSampleBufferDelegate(self, queue: schemeScanningQueue)
    }

    private func performCaptureChecksForDevice(_ device: AVCaptureDevice) {
        do {
            try device.lockForConfiguration()
        } catch let error {
            // TODO: Handle error
            print(error.localizedDescription)
        }

        if device.isFocusModeSupported(.continuousAutoFocus) {
            device.focusMode = .continuousAutoFocus
        }

        if device.isSmoothAutoFocusSupported {
            device.isSmoothAutoFocusEnabled = true
        }

        device.isSubjectAreaChangeMonitoringEnabled = true

        if device.isFocusPointOfInterestSupported {
            device.focusPointOfInterest = CGPoint(x: 0.5, y: 0.5)
        }

        if device.isAutoFocusRangeRestrictionSupported {
            device.autoFocusRangeRestriction = .near
        }

        if device.isLowLightBoostSupported {
            device.automaticallyEnablesLowLightBoostWhenAvailable = true
        }

        device.activeVideoMaxFrameDuration = CMTime(value: 1, timescale: 10)
        device.activeVideoMinFrameDuration = CMTime(value: 1, timescale: 10)
        device.unlockForConfiguration()
    }
}

extension LoyaltyScannerViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if schemeIdentifierSample == nil {
            schemeIdentifierSample = BINKLoyaltyScannerSchemeIdentifierSample(buffer: sampleBuffer, from: connection)
        } else {
            schemeIdentifierSample.update(with: sampleBuffer, from: connection)
        }

        schemeIdentifierSample.cardImage(withGuide: rectOfInterest, screenSize: viewFrame.size) { [weak self] (image, topOffset) in
            guard let image = image else { return }
            guard self?.visionShouldProcessFrame == true else { return }
            self?.visionShouldProcessFrame = false

            DispatchQueue.main.asyncAfter(deadline: .now() + LoyaltyScannerViewController.visionRateLimit) {
                self?.visionShouldProcessFrame = true
            }

            // TODO: Move to it's own method
            let rectRequest = VNDetectRectanglesRequest { (request, error) in
                guard let observation = request.results?.first as? VNRectangleObservation else { return }
                guard observation.boundingBox != CGRect.zero else { return }

                let transformedRect = CGRect(x: observation.boundingBox.origin.x, y: 1 - observation.boundingBox.origin.y, width: observation.boundingBox.size.width, height: observation.boundingBox.size.height)
                let width = image.size.width * transformedRect.size.width
                let height = image.size.height * transformedRect.size.height
                let x = image.size.width * transformedRect.origin.x
                let y = (image.size.height * transformedRect.origin.y) - height
                let rectResultImagePadding: CGFloat = 40
                let rectInImage = CGRect(x: x, y: y, width: width, height: height)
                guard let cgImage = image.cgImage else { return }
                guard let croppedRef = cgImage.cropping(to: rectInImage.inset(by: UIEdgeInsets(top: rectResultImagePadding, left: rectResultImagePadding, bottom: rectResultImagePadding, right: rectResultImagePadding))) else { return }
                let croppedImage = UIImage(cgImage: croppedRef)
                // TODO: cgImage release?

                // TODO: Move to it's own method
                let barcodeRequest = VNDetectBarcodesRequest { (request, error) in
                    let result = request.results?.first(where: {
                        let result = $0 as? VNBarcodeObservation
                        let url = URL(string: result?.payloadStringValue ?? "")
                        return url != nil
                    })
                    guard let validResult = result as? VNBarcodeObservation else { return }
                    guard let barcodeString = validResult.payloadStringValue else { return }
                    guard self?.isLaunching == false else { return }

                    DispatchQueue.main.async {
                        let schemeFromBarcode = CD_MembershipPlan.planFromBarcode(barcodeString)
                        if schemeFromBarcode != nil {
                            self?.isLaunching = true
                            // TODO: Begin add journey here, call to router with scheme and barcode
                        } else {
                            self?.isLaunching = false
                            // TODO: If we have no scan questions for the scheme, then we need to stop them here or no scheme matching their barcode.
                        }
                    }
                }

                guard let croppedCGImage = croppedImage.cgImage else { return }
                let handler = VNImageRequestHandler(cgImage: croppedCGImage, options: [:])
                try? handler.perform([barcodeRequest])
            }
            rectRequest.minimumAspectRatio = 0.9

            // TODO: Move to it's own method
            let barcodeRequest = VNDetectBarcodesRequest { [weak self] (request, error) in
                let result = request.results?.first(where: {
                    let result = $0 as? VNBarcodeObservation
                    let url = URL(string: result?.payloadStringValue ?? "")
                    return url != nil
                })
                guard let validResult = result as? VNBarcodeObservation else { return }
                guard let barcodeString = validResult.payloadStringValue else { return }
                guard self?.isLaunching == false else { return }

                DispatchQueue.main.async {
                    let schemeFromBarcode = CD_MembershipPlan.planFromBarcode(barcodeString)
                    if schemeFromBarcode != nil {
                        self?.isLaunching = true
                        // TODO: Begin add journey here, call to router with scheme and barcode
                    } else {
                        self?.isLaunching = false
                        // TODO: If we have no scan questions for the scheme, then we need to stop them here or no scheme matching their barcode.
                    }
                }
            }

            guard let cgImage = image.cgImage else { return }
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            try? handler.perform([barcodeRequest, rectRequest])
        }
    }
}

extension CD_MembershipPlan {
    static func planFromBarcode(_ barcode: String) -> CD_MembershipPlan? {
        let plan = CD_MembershipPlan()
        plan.account?.companyName = "Nick's Plan"
        return plan
    }
}
