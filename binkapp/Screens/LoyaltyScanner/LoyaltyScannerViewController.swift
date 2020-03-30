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

    var isLaunching = false
    var visionShouldProcessFrame = false
    var identificationApiShouldProcessFrame = false
    var isProcessingIdentificationApi = false
    var schemeIdentificationFailureCount = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        view.addSubview(previewView)

        startScanning()
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

    private func prepareSchemeScannerOutput() {
        captureSchemeOutput.alwaysDiscardsLateVideoFrames = true
        captureSchemeOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "com.bink.wallet.scanning.loyalty.scheme.queue"))
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

}
