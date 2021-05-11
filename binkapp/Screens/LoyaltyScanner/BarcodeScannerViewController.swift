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
    let plan: CD_MembershipPlan?
    var isScanning: Bool = false
    
    var hasPlan: Bool {
        return plan != nil
    }
}

protocol BarcodeScannerViewControllerDelegate: AnyObject {
    func barcodeScannerViewController(_ viewController: BarcodeScannerViewController, didScanBarcode barcode: String, forMembershipPlan membershipPlan: CD_MembershipPlan, completion: (() -> Void)?)
    func barcodeScannerViewControllerShouldEnterManually(_ viewController: BarcodeScannerViewController, completion: (() -> Void)?)
}

class BarcodeScannerViewController: BinkViewController {
    enum Constants {
        static let rectOfInterestInset: CGFloat = 25
        static let viewFrameRatio: CGFloat = 12 / 18
        static let maskedAreaY: CGFloat = 100
        static let maskedAreaCornerRadius: CGFloat = 8
        static let guideImageInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        static let explainerLabelPadding: CGFloat = 25
        static let explainerLabelHeight: CGFloat = 22
        static let widgetViewTopPadding: CGFloat = 30
        static let widgetViewLeftRightPadding: CGFloat = 25
        static let widgetViewHeight: CGFloat = 100
        static let closeButtonSize = CGSize(width: 44, height: 44)
        static let timerInterval: TimeInterval = 5.0
        static let scanErrorThreshold: TimeInterval = 1.0
    }

    private weak var delegate: BarcodeScannerViewControllerDelegate?

    private var session = AVCaptureSession()
    private var captureOutput: AVCaptureMetadataOutput?
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    private var previewView = UIView()
    private let schemeScanningQueue = DispatchQueue(label: "com.bink.wallet.scanning.loyalty.scheme.queue")
    private var rectOfInterest = CGRect.zero
    private var timer: Timer?
    private var canPresentScanError = true
    private var shouldShowNavigationBar = false

    private lazy var blurredView: UIVisualEffectView = {
        return UIVisualEffectView(effect: UIBlurEffect(style: .regular))
    }()

    private lazy var guideImageView: UIImageView = {
        let imageView = UIImageView(image: Asset.scannerGuide.image)
        return imageView
    }()

    private lazy var explainerLabel: UILabel = {
        let label = UILabel()
        label.text = L10n.loyaltyScannerExplainerText
        label.font = .bodyTextLarge
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()

    private lazy var widgetView: LoyaltyScannerWidgetView = {
        let widget = LoyaltyScannerWidgetView()
        widget.addTarget(self, selector: #selector(enterManually))
        widget.translatesAutoresizingMaskIntoConstraints = false
        return widget
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(Asset.close.image, for: .normal)
        button.addTarget(self, action: #selector(close), for: .touchUpInside)
        return button
    }()

    private var viewModel: BarcodeScannerViewModel

    init(viewModel: BarcodeScannerViewModel, showNavigationBar: Bool = false, delegate: BarcodeScannerViewControllerDelegate?) {
        self.viewModel = viewModel
        self.delegate = delegate
        self.shouldShowNavigationBar = showNavigationBar
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(previewView)

        // BLUR AND MASK
        blurredView.frame = view.frame
        let maskLayer = CAShapeLayer()
        maskLayer.frame = view.frame
        // Setup rect of interest
        let inset = Constants.rectOfInterestInset
        let width = view.frame.size.width - (inset * 2)
        let viewFrameRatio = Constants.viewFrameRatio
        let height: CGFloat = floor(viewFrameRatio * width)
        let maskedAreaFrame = CGRect(x: inset, y: Constants.maskedAreaY, width: width, height: height)
        rectOfInterest = maskedAreaFrame
        let maskedPath = UIBezierPath(roundedRect: rectOfInterest, cornerRadius: Constants.maskedAreaCornerRadius)
        maskedPath.append(UIBezierPath(rect: view.bounds))
        maskLayer.fillRule = .evenOdd
        maskLayer.path = maskedPath.cgPath
        blurredView.layer.mask = maskLayer
        view.addSubview(blurredView)

        guideImageView.frame = rectOfInterest.inset(by: Constants.guideImageInset)
        view.addSubview(guideImageView)

        view.addSubview(explainerLabel)
        view.addSubview(widgetView)
        NSLayoutConstraint.activate([
            explainerLabel.topAnchor.constraint(equalTo: guideImageView.bottomAnchor, constant: Constants.explainerLabelPadding),
            explainerLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: Constants.explainerLabelPadding),
            explainerLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -Constants.explainerLabelPadding),
            explainerLabel.heightAnchor.constraint(equalToConstant: Constants.explainerLabelHeight),
            widgetView.topAnchor.constraint(equalTo: explainerLabel.bottomAnchor, constant: Constants.widgetViewTopPadding),
            widgetView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: Constants.widgetViewLeftRightPadding),
            widgetView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -Constants.widgetViewLeftRightPadding),
            widgetView.heightAnchor.constraint(equalToConstant: Constants.widgetViewHeight)
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !shouldShowNavigationBar {
            navigationController?.setNavigationBarHidden(true, animated: false)
            
            view.addSubview(cancelButton)
            NSLayoutConstraint.activate([
                cancelButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 4),
                cancelButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -4),
                cancelButton.heightAnchor.constraint(equalToConstant: Constants.closeButtonSize.height),
                cancelButton.widthAnchor.constraint(equalToConstant: Constants.closeButtonSize.width)
            ])
        }


        if !viewModel.isScanning {
            startScanning()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopScanning()
    }

    override func configureForCurrentTheme() {
        super.configureForCurrentTheme()
        blurredView.backgroundColor = Current.themeManager.color(for: .bar)
        explainerLabel.textColor = Current.themeManager.color(for: .text)
        cancelButton.tintColor = Current.themeManager.color(for: .text)
        widgetView.configure()
    }

    private func startScanning() {
        viewModel.isScanning = true
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

        guard let captureOutput = captureOutput else { return }

        if session.outputs.isEmpty {
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

        timer = Timer.scheduledTimer(withTimeInterval: Constants.timerInterval, repeats: false, block: { [weak self] _ in
            self?.widgetView.timeout()
        })
    }

    private func stopScanning() {
        viewModel.isScanning = false
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
            if #available(iOS 14.0, *) {
                BinkLogger.error(AppLoggerError.lockDeviceForAVCaptureConfig, value: error.localizedDescription)
            }
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
    
    @objc private func close() {
        Current.navigate.close()
    }
}

extension BarcodeScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        timer?.invalidate()
        
        //TODO: Tidy this up by splitting to other functions

        if let object = metadataObjects.first {
            guard let readableObject = object as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            Current.wallet.identifyMembershipPlanForBarcode(stringValue) { [weak self] plan in
                guard let self = self else { return }
                guard let plan = plan else {
                    if self.canPresentScanError {
                        self.canPresentScanError = false
                        DispatchQueue.main.async { [weak self] in
                            guard let self = self else { return }
                            self.widgetView.unrecognizedBarcode()
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.scanErrorThreshold, execute: { [weak self] in
                            self?.canPresentScanError = true
                        })
                    }
                    return
                }
                
                if #available(iOS 14.0, *) {
                    BinkLogger.infoPrivateHash(event: AppLoggerEvent.barcodeScanned, value: "ID: \(plan.id ?? "") - \(stringValue)")
                }
                
                // We recognised the plan, but is this the plan we injected if any?
                if let planFromForm = self.viewModel.plan {
                    // We injected a plan from a form
                    if plan != planFromForm {
                        if self.canPresentScanError {
                            self.canPresentScanError = false
                            DispatchQueue.main.async {
                                if #available(iOS 14.0, *) {
                                    BinkLogger.error(AppLoggerError.barcodeScanningFailure, value: planFromForm.account?.companyName)
                                }
                                HapticFeedbackUtil.giveFeedback(forType: .notification(type: .error))
                                let alert = BinkAlertController(title: "Error", message: "The card you scanned was not correct, please scan your \(planFromForm.account?.companyName ?? "") card", preferredStyle: .alert)
                                let action = UIAlertAction(title: "OK", style: .cancel) { _ in
                                    DispatchQueue.main.asyncAfter(deadline: .now() + Constants.scanErrorThreshold, execute: {
                                        self.canPresentScanError = true
                                    })
                                }
                                alert.addAction(action)
                                self.present(alert, animated: true, completion: nil)
                            }
                        }
                    } else {
                        self.stopScanning()
                        HapticFeedbackUtil.giveFeedback(forType: .notification(type: .success))
                        
                        DispatchQueue.main.async { [weak self] in
                            guard let self = self else { return }
                            self.delegate?.barcodeScannerViewController(self, didScanBarcode: stringValue, forMembershipPlan: plan, completion: nil)
                        }
                    }
                } else {
                    self.stopScanning()
                    HapticFeedbackUtil.giveFeedback(forType: .notification(type: .success))
                    
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        self.delegate?.barcodeScannerViewController(self, didScanBarcode: stringValue, forMembershipPlan: plan, completion: nil)
                    }
                }
            }
        }
    }
}
