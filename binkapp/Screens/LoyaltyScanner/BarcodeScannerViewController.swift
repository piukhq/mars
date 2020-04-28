//
//  BarcodeScannerViewController.swift
//  binkapp
//
//  Created by Nick Farrant on 02/04/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import UIKit
import AVFoundation

struct BarcodeScannerViewModel {
    
}

protocol BarcodeScannerViewControllerDelegate: AnyObject {
    func barcodeScannerViewController(_ viewController: BarcodeScannerViewController, didScanBarcode barcode: String, forMembershipPlan membershipPlan: CD_MembershipPlan, completion: (() -> Void)?)
    func barcodeScannerViewControllerShouldEnterManually(_ viewController: BarcodeScannerViewController, completion: (() -> Void)?)
}

class BarcodeScannerViewController: UIViewController {
    private weak var delegate: BarcodeScannerViewControllerDelegate?

    private var session = AVCaptureSession()
    private var captureOutput: AVCaptureMetadataOutput!
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    private var previewView = UIView()
    private let schemeScanningQueue = DispatchQueue(label: "com.bink.wallet.scanning.loyalty.scheme.queue")
    private var rectOfInterest = CGRect.zero
    private var timer: Timer?
    private var hasPresentedScanError = false

    private lazy var blurredView: UIVisualEffectView = {
        return UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
    }()

    private lazy var guideImageView: UIImageView = {
        let image = UIImage(named: "scanner_guide")
        let imageView = UIImageView(image: image)
        return imageView
    }()

    private lazy var explainerLabel: UILabel = {
        let label = UILabel()
        label.text = "Hold card here. It will scan automatically."
        label.font = .bodyTextLarge
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var widgetView: LoyaltyScannerWidgetView = {
        let widget = LoyaltyScannerWidgetView()
        widget.addTarget(self, selector: #selector(enterManually))
        widget.translatesAutoresizingMaskIntoConstraints = false
        return widget
    }()

    private let viewModel: BarcodeScannerViewModel

    init(viewModel: BarcodeScannerViewModel, delegate: BarcodeScannerViewControllerDelegate?) {
        self.viewModel = viewModel
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

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
        let inset: CGFloat = 25
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

        guideImageView.frame = rectOfInterest.inset(by: UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16))
        view.addSubview(guideImageView)

        view.addSubview(explainerLabel)
        view.addSubview(widgetView)
        NSLayoutConstraint.activate([
            explainerLabel.topAnchor.constraint(equalTo: guideImageView.bottomAnchor, constant: 25),
            explainerLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 25),
            explainerLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -25),
            explainerLabel.heightAnchor.constraint(equalToConstant: 22),
            widgetView.topAnchor.constraint(equalTo: explainerLabel.bottomAnchor, constant: 30),
            widgetView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 25),
            widgetView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -25),
            widgetView.heightAnchor.constraint(equalToConstant: 100),
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.addSubview(backButton)
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            backButton.leftAnchor.constraint(equalTo: view.leftAnchor),
            backButton.heightAnchor.constraint(equalToConstant: 44),
            backButton.widthAnchor.constraint(equalToConstant: 44),
        ])

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
        captureOutput = AVCaptureMetadataOutput()

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
            if session.canAddOutput(captureOutput) {
                session.addOutput(captureOutput)
                captureOutput.setMetadataObjectsDelegate(self, queue: schemeScanningQueue)
                captureOutput.metadataObjectTypes = [
                    .qr,
                    .code128,
                    .aztec,
                    .pdf417,
                    .ean13,
                    .dataMatrix,
                    .interleaved2of5,
                    .code39
                ]
            }
        }

        if !session.isRunning {
            session.startRunning()
        }

        captureOutput.rectOfInterest = videoPreviewLayer.metadataOutputRectConverted(fromLayerRect: rectOfInterest)

        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false, block: { [weak self] _ in
            self?.widgetView.timeout()
        })
    }

    private func stopScanning() {
        schemeScanningQueue.async { [weak self] in
            self?.session.stopRunning()
            guard let outputs = self?.session.outputs else { return }
            for output in outputs {
                self?.session.removeOutput(output)
            }
            self?.timer?.invalidate()
        }
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

    @objc private func enterManually() {
        delegate?.barcodeScannerViewControllerShouldEnterManually(self, completion: { [weak self] in
            guard let self = self else { return }
            self.navigationController?.removeViewController(self)
        })
    }
}

extension BarcodeScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        timer?.invalidate()

        if let object = metadataObjects.first {
            guard let readableObject = object as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            Current.wallet.identifyMembershipPlanForBarcode(stringValue) { [weak self] plan in
                guard let self = self else { return }
                guard let plan = plan else {
                    if !self.hasPresentedScanError {
                        self.hasPresentedScanError = true
                        DispatchQueue.main.async { [weak self] in
                            guard let self = self else { return }
                            self.widgetView.unrecognizedBarcode()
                        }
                    }
                    return
                }
                self.stopScanning()
                HapticFeedbackUtil.giveFeedback(forType: .notification(type: .success))

                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.delegate?.barcodeScannerViewController(self, didScanBarcode: stringValue, forMembershipPlan: plan, completion: {
                        self.navigationController?.removeViewController(self)
                    })
                }
            }
        }
    }
}
