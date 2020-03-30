//
//  LoyaltyScannerViewController.swift
//  binkapp
//
//  Created by Nick Farrant on 26/03/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import UIKit
import AVFoundation
//import Vision

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

    var rectOfInterest = CGRect.zero

    var schemeIdentifierSample: BINKLoyaltyScannerSchemeIdentifierSample!

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
    }
}
