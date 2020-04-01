//
//  BarcodeScannerViewController.swift
//  binkapp
//
//  Created by Nick Farrant on 31/03/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import UIKit
import Vision
import AVFoundation

class BarcodeScannerViewController: UIViewController {

    var session = AVCaptureSession()
    var captureSchemeOutput: AVCaptureVideoDataOutput!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    var previewView = UIView()

    let schemeScanningQueue = DispatchQueue(label: "com.bink.wallet.scanning.loyalty.scheme.queue")

    var isLaunching = false
    var visionShouldProcessFrame = false
    static let visionRateLimit = 0.2

    var schemeIdentifierSample: BINKLoyaltyScannerSchemeIdentifierSample!
    var rectOfInterest = CGRect.zero
    var viewFrame = CGRect.zero

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

extension BarcodeScannerViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // TODO: Get output from rectOfInterest

        // Convert output to image
        let imageBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
        let ciimage : CIImage = CIImage(cvPixelBuffer: imageBuffer)
        let image : UIImage = self.convert(cmage: ciimage)

        guard visionShouldProcessFrame == true else { return }
        visionShouldProcessFrame = false

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            self?.visionShouldProcessFrame = true
        }

        let barcodeRequest = VNDetectBarcodesRequest { (request, error) in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }

            DispatchQueue.main.async {
                if let bestResult = request.results?.first as? VNBarcodeObservation,
                    let payload = bestResult.payloadStringValue {
                    print(payload)
                } else {

                }
            }
        }

        // Convert image to CIImage. Do we need this if we already had the ci image?
        guard let ciImage = CIImage(image: image) else {
            fatalError("Unable to create \(CIImage.self) from \(image).")
        }

        // Perform the classification request on a background thread.
        DispatchQueue.global(qos: .userInitiated).async {
            let handler = VNImageRequestHandler(ciImage: ciImage, orientation: CGImagePropertyOrientation.up, options: [:])

            do {
                try handler.perform([barcodeRequest])
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }

    func convert(cmage:CIImage) -> UIImage {
         let context:CIContext = CIContext.init(options: nil)
         let cgImage:CGImage = context.createCGImage(cmage, from: cmage.extent)!
         let image:UIImage = UIImage.init(cgImage: cgImage)
         return image
    }
}
