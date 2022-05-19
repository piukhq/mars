//
//  BarcodeScannerViewController.swift
//  binkapp
//
//  Created by Nick Farrant on 02/04/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import UIKit
import AVFoundation
import Vision

enum ScanType {
    case loyalty
    case payment
}

struct BarcodeScannerViewModel {
    let plan: CD_MembershipPlan?
    let type: ScanType
    var isScanning = false
    
    var hasPlan: Bool {
        return plan != nil
    }
}

enum BarcodeCaptureSource {
    case camera(CD_MembershipPlan?)
    case photoLibrary(CD_MembershipPlan?)
    
    var errorMessage: String {
        switch self {
        case .camera(let membershipPlan):
            return "The card you scanned was not correct, please scan your \(membershipPlan?.account?.companyName ?? "") card"
        case .photoLibrary(let membershipPlan):
            return "Unrecognized barcode, please import an image of your \(membershipPlan?.account?.companyName ?? "") barcode"
        }
    }
}

protocol BarcodeScannerViewControllerDelegate: AnyObject {
    func barcodeScannerViewController(_ viewController: BarcodeScannerViewController, didScanBarcode barcode: String, forMembershipPlan membershipPlan: CD_MembershipPlan, completion: (() -> Void)?)
    func barcodeScannerViewControllerShouldEnterManually(_ viewController: BarcodeScannerViewController, completion: (() -> Void)?)
}

class BarcodeScannerViewController: BinkViewController, UINavigationControllerDelegate {
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
    private var captureOutput: AVCaptureOutput?
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    private var previewView = UIView()
    private let schemeScanningQueue = DispatchQueue(label: "com.bink.wallet.scanning.loyalty.scheme.queue")
    private var rectOfInterest = CGRect.zero
    private var timer: Timer?
    private var canPresentScanError = true
    private var hideNavigationBar = true
    private var shouldAllowScanning = true
    private var captureSource: BarcodeCaptureSource
    private let visionUtility = VisionImageDetectionUtility()
    private var paymentCardRectangleObservation: VNRectangleObservation?
    private var trackingRect: CAShapeLayer?
    private let requestHandler = VNSequenceRequestHandler()


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
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()

    private lazy var widgetView: LoyaltyScannerWidgetView = {
        let widget = LoyaltyScannerWidgetView()
        widget.addTarget(self, selector: #selector(enterManually))
        widget.translatesAutoresizingMaskIntoConstraints = false
        return widget
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(Asset.close.image, for: .normal)
        button.addTarget(self, action: #selector(close), for: .touchUpInside)
        return button
    }()
    
    private lazy var photoLibraryButton: BinkButton = {
        return BinkButton(type: .plain, title: L10n.loyaltyScannerAddPhotoFromLibraryButtonTitle, enabled: true, action: { [weak self] in
            self?.toPhotoLibrary()
        })
    }()

    private var viewModel: BarcodeScannerViewModel

    init(viewModel: BarcodeScannerViewModel, hideNavigationBar: Bool = true, delegate: BarcodeScannerViewControllerDelegate?) {
        self.viewModel = viewModel
        self.delegate = delegate
        self.hideNavigationBar = hideNavigationBar
        self.captureSource = .camera(viewModel.plan)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(previewView)

//        // BLUR AND MASK
//        blurredView.frame = view.frame
//        let maskLayer = CAShapeLayer()
//        maskLayer.frame = view.frame
//        // Setup rect of interest
//        let inset = Constants.rectOfInterestInset
//        let width = view.frame.size.width - (inset * 2)
//        let viewFrameRatio = Constants.viewFrameRatio
//        let height: CGFloat = floor(viewFrameRatio * width)
//        let maskedAreaFrame = CGRect(x: inset, y: Constants.maskedAreaY, width: width, height: height)
//        rectOfInterest = maskedAreaFrame
//        let maskedPath = UIBezierPath(roundedRect: rectOfInterest, cornerRadius: Constants.maskedAreaCornerRadius)
//        maskedPath.append(UIBezierPath(rect: view.bounds))
//        maskLayer.fillRule = .evenOdd
//        maskLayer.path = maskedPath.cgPath
//        blurredView.layer.mask = maskLayer
//        view.addSubview(blurredView)

//        guideImageView.frame = rectOfInterest.inset(by: Constants.guideImageInset)
//        view.addSubview(guideImageView)
//        view.addSubview(explainerLabel)
//        view.addSubview(widgetView)
        
//        footerButtons = [photoLibraryButton]
        
//        NSLayoutConstraint.activate([
//            explainerLabel.topAnchor.constraint(equalTo: guideImageView.bottomAnchor, constant: Constants.explainerLabelPadding),
//            explainerLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: Constants.explainerLabelPadding),
//            explainerLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -Constants.explainerLabelPadding),
//            explainerLabel.heightAnchor.constraint(equalToConstant: Constants.explainerLabelHeight),
//            widgetView.topAnchor.constraint(equalTo: explainerLabel.bottomAnchor, constant: Constants.widgetViewTopPadding),
//            widgetView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: Constants.widgetViewLeftRightPadding),
//            widgetView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -Constants.widgetViewLeftRightPadding),
//            widgetView.heightAnchor.constraint(equalToConstant: Constants.widgetViewHeight)
//        ])
        
        navigationController?.setNavigationBarVisibility(false)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if hideNavigationBar {
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
        navigationController?.setNavigationBarVisibility(true)
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

        if session.canAddInput(input) {
            session.addInput(input)
        }

        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
        guard let videoPreviewLayer = videoPreviewLayer else { return }
        videoPreviewLayer.videoGravity = .resizeAspect
        videoPreviewLayer.connection?.videoOrientation = .portrait

        previewView.layer.addSublayer(videoPreviewLayer)
        videoPreviewLayer.frame = view.frame

//        guard let captureOutput = captureOutput else { return }

        switch viewModel.type {
        case .loyalty:
            let metadataCaptureOutput = AVCaptureMetadataOutput()
            if session.outputs.isEmpty {
                if session.canAddOutput(metadataCaptureOutput) {
                    session.addOutput(metadataCaptureOutput)
                                    
                    metadataCaptureOutput.setMetadataObjectsDelegate(self, queue: schemeScanningQueue)
                    metadataCaptureOutput.metadataObjectTypes = [
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
            metadataCaptureOutput.rectOfInterest = videoPreviewLayer.metadataOutputRectConverted(fromLayerRect: rectOfInterest)
            captureOutput = metadataCaptureOutput
        case .payment:
            let videoOutput = AVCaptureVideoDataOutput()
            videoOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString): NSNumber(value: kCVPixelFormatType_32BGRA)] as [String : Any]
            videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "my.image.handling.queue")) /// Change to global variable queue?
            
            if session.outputs.isEmpty {
                if session.canAddOutput(videoOutput) {
                    session.addOutput(videoOutput)
                }
            }
            
            guard let connection = videoOutput.connection(with: AVMediaType.video), connection.isVideoOrientationSupported else { return }
            connection.videoOrientation = .portrait
            
//            let cameraLayer = AVCaptureVideoPreviewLayer(session: session)
//            cameraLayer.frame = rectOfInterest
//            view.layer.addSublayer(cameraLayer)
            captureOutput = videoOutput
        }

        if !session.isRunning {
            session.startRunning()
        }

        scheduleTimer()
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
    
    private func scheduleTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: Constants.timerInterval, repeats: false, block: { [weak self] _ in
            self?.widgetView.timeout()
        })
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

    private func toPhotoLibrary() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        picker.modalPresentationStyle = .overCurrentContext
        captureSource = .photoLibrary(viewModel.plan)
        timer?.invalidate()
        let navigationRequest = ModalNavigationRequest(viewController: picker, embedInNavigationController: false)
        Current.navigate.to(navigationRequest)
    }
    
    @objc private func enterManually() {
//        let photoSettings = AVCapturePhotoSettings()
//        if let photoPreviewType = photoSettings.availablePreviewPhotoPixelFormatTypes.first {
//            photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: photoPreviewType]
//            if let photoOutput = captureOutput as? AVCapturePhotoOutput {
//                photoOutput.capturePhoto(with: photoSettings, delegate: self)
//            }
//        }
        
        
//        delegate?.barcodeScannerViewControllerShouldEnterManually(self, completion: { [weak self] in
//            guard let self = self else { return }
//            self.navigationController?.removeViewController(self)
//        })
    }
    
    @objc private func close() {
        Current.navigate.close()
    }
    
    private func identifyMembershipPlanForBarcode(_ barcode: String) {
        Current.wallet.identifyMembershipPlanForBarcode(barcode) { [weak self] plan in
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
                BinkLogger.infoPrivateHash(event: AppLoggerEvent.barcodeScanned, value: "ID: \(plan.id ?? "") - \(barcode)")
            }
            
            self.passDataToBarcodeScannerDelegate(barcode: barcode, membershipPlan: plan)
        }
    }
    
    private func passDataToBarcodeScannerDelegate(barcode: String, membershipPlan: CD_MembershipPlan) {
        // We recognised the plan, but is this the plan we injected if any?
        if let planFromForm = self.viewModel.plan {
            // We injected a plan from a form
            if membershipPlan != planFromForm {
                if self.canPresentScanError {
                    self.canPresentScanError = false
                    DispatchQueue.main.async {
                        if #available(iOS 14.0, *) {
                            BinkLogger.error(AppLoggerError.barcodeScanningFailure, value: planFromForm.account?.companyName)
                        }
                        HapticFeedbackUtil.giveFeedback(forType: .notification(type: .error))
                        self.showError(barcodeDetected: true)
                    }
                }
            } else {
                self.stopScanning()
                HapticFeedbackUtil.giveFeedback(forType: .notification(type: .success))
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.delegate?.barcodeScannerViewController(self, didScanBarcode: barcode, forMembershipPlan: membershipPlan, completion: nil)
                }
            }
        } else {
            self.stopScanning()
            HapticFeedbackUtil.giveFeedback(forType: .notification(type: .success))
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.barcodeScannerViewController(self, didScanBarcode: barcode, forMembershipPlan: membershipPlan, completion: nil)
            }
        }
    }
    
    private func showError(barcodeDetected: Bool) {
        let alert = BinkAlertController(title: L10n.errorTitle, message: barcodeDetected ? captureSource.errorMessage : L10n.loyaltyScannerFailedToDetectBarcode, preferredStyle: .alert)
        let action = UIAlertAction(title: L10n.ok, style: .cancel) { [weak self] _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + Constants.scanErrorThreshold, execute: {
                self?.canPresentScanError = true
                self?.shouldAllowScanning = true
                if !barcodeDetected {
                    self?.scheduleTimer()
                }
            })
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
}

extension BarcodeScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        timer?.invalidate()
        guard shouldAllowScanning else { return }
        shouldAllowScanning = false

        if let object = metadataObjects.first {
            guard let readableObject = object as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            captureSource = .camera(viewModel.plan)
            identifyMembershipPlanForBarcode(stringValue)
        }
    }
}

// MARK: - Detect barcode from image

extension BarcodeScannerViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        Current.navigate.close(animated: true) { [weak self] in
            self?.visionUtility.createVisionRequest(image: image) { barcode in
                guard let barcode = barcode else {
                    self?.showError(barcodeDetected: false)
                    return
                }
                self?.identifyMembershipPlanForBarcode(barcode)
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        Current.navigate.close(animated: true) {
            self.scheduleTimer()
        }
    }
}

//extension BarcodeScannerViewController: AVCapturePhotoCaptureDelegate {
//    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
//        guard let imageData = photo.fileDataRepresentation() else { return }
//        if let image = UIImage(data: imageData) {
//            VisionImageDetectionUtility().processImage(image)
//        }
//    }
//}

extension BarcodeScannerViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let frame = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            print("Unable to get image from sample buffer")
            return
        }
        
        DispatchQueue.main.async {
            self.trackingRect?.removeFromSuperlayer() // removes old rectangle drawings
        }
        if let paymentCardRectangleObservation = self.paymentCardRectangleObservation {
            self.handleObservedPaymentCard(paymentCardRectangleObservation, in: frame)
        } else if let paymentCardRectangleObservation = self.detectPaymentCard(frame: frame) {
            self.paymentCardRectangleObservation = paymentCardRectangleObservation
        }
    }
    
    func detectPaymentCard(frame: CVImageBuffer) -> VNRectangleObservation? {
        let rectangleDetectionRequest = VNDetectRectanglesRequest()
//        let paymentCardAspectRatio: Float = 85.60 / 53.98
//        rectangleDetectionRequest.minimumAspectRatio = paymentCardAspectRatio * 0.95
//        rectangleDetectionRequest.maximumAspectRatio = paymentCardAspectRatio * 0.10
        
        let textDetectionRequest = VNDetectTextRectanglesRequest()
        
        try? self.requestHandler.perform([rectangleDetectionRequest, textDetectionRequest], on: frame)
        
        guard let rectangle = (rectangleDetectionRequest.results)?.first,
              let text = (textDetectionRequest.results)?.first,
            rectangle.boundingBox.contains(text.boundingBox) else {
                // no credit card rectangle detected
                return nil
        }
        
        return rectangle
    }
    
    private func handleObservedPaymentCard(_ observation: VNRectangleObservation, in frame: CVImageBuffer) {
        if let trackedPaymentCardRectangle = self.trackPaymentCard(for: observation, in: frame) {
            DispatchQueue.main.async {
                self.trackingRect?.removeFromSuperlayer()
                self.trackingRect = self.createRectangleDrawring(trackedPaymentCardRectangle)
                self.view.layer.addSublayer(self.trackingRect!)
            }
            
            DispatchQueue.global(qos: .userInitiated).async {
                if let textObservations = self.getCandidates(frame: frame, rectangle: observation) {
                    if let paymentCardNumber = self.extractPaymentCardNumber(texts: textObservations) {
                        print("Card Number: - \(paymentCardNumber)")
                    }

                    if let expiry = self.extractExpiryDate(observations: textObservations) {
                        print("Expiry: - \(expiry)")
                    }
                }
            }
        } else {
            self.paymentCardRectangleObservation = nil
        }
    }
    
    private func getCandidates(frame: CVImageBuffer, rectangle: VNRectangleObservation) -> [VNRecognizedTextObservation]? {
        let cardPositionInImage = VNImageRectForNormalizedRect(rectangle.boundingBox, CVPixelBufferGetWidth(frame), CVPixelBufferGetHeight(frame))
        let ciImage = CIImage(cvImageBuffer: frame)
        let croppedImage = ciImage.cropped(to: cardPositionInImage)
        
        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = false
        
        let stillImageRequestHandler = VNImageRequestHandler(ciImage: croppedImage, options: [:])
        try? stillImageRequestHandler.perform([request])
        
        guard let observations = request.results, !observations.isEmpty else {
            // no text detected
            return nil
        }
        
        return observations
    }
    
    private func extractPaymentCardNumber(texts: [VNRecognizedTextObservation]) -> String? {
        let recognizedText = texts.compactMap { observation in
            return observation.topCandidates(1).first?.string
        }
        
        let creditCard = parseResults(for: recognizedText)
        return creditCard
    }
    
    func parseResults(for recognizedText: [String]) -> String? {
        let creditCardNumber = recognizedText.first(where: { $0.count > 14 && ["4", "5", "3", "6"].contains($0.first) })
        return creditCardNumber
    }
    
    private func extractExpiryDate(observations: [VNRecognizedTextObservation]) -> (String, String)? {
        for text in observations.flatMap( {$0.topCandidates(1)}) {
            if let expiry = likelyExpiry(text.string) {
                return expiry
            }
        }
        return nil
    }
    
    private func trackPaymentCard(for observation: VNRectangleObservation, in frame: CVImageBuffer) -> VNRectangleObservation? {
        let request = VNTrackRectangleRequest(rectangleObservation: observation)
        request.trackingLevel = .fast
        
        try? self.requestHandler.perform([request], on: frame)
        
        guard let trackedRectangle = (request.results as? [VNRectangleObservation])?.first else {
            return nil
        }
        return trackedRectangle
    }
    
    private func createRectangleDrawring(_ rectangleObservation: VNRectangleObservation) -> CAShapeLayer {
        let transform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -self.view.frame.height)
        let scale = CGAffineTransform.identity.scaledBy(x: self.view.frame.width, y: self.view.frame.height)
        let rectOnScreen = rectangleObservation.boundingBox.applying(scale).applying(transform)
        let boundingBoxPath = CGPath(rect: rectOnScreen, transform: nil)
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = boundingBoxPath
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.white.cgColor
        shapeLayer.lineWidth = 5
        shapeLayer.borderWidth = 5
        return shapeLayer
    }
    
    private func checkDigits(_ digits: String) -> Bool {
        guard digits.count == 16, CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: digits)) else {
            return false
        }
        var digits = digits
        let checksum = digits.removeLast()
        let sum = digits.reversed()
            .enumerated()
            .map({ (index, element) -> Int in
                if (index % 2) == 0 {
                   let doubled = Int(String(element))!*2
                   return doubled > 9
                       ? Int(String(String(doubled).first!))! + Int(String(String(doubled).last!))!
                       : doubled
                } else {
                    return Int(String(element))!
                }
            })
            .reduce(0, { (res, next) in res + next })
        let checkDigitCalc = (sum * 9) % 10
        return Int(String(checksum))! == checkDigitCalc
    }
    
    func likelyExpiry(_ string: String) -> (String, String)? {
        guard let regex = try? NSRegularExpression(pattern: "^.*(0[1-9]|1[0-2])[./]([1-2][0-9])$") else {
            return nil
        }

        let result = regex.matches(in: string, range: NSRange(string.startIndex..., in: string))
        
        if result.isEmpty {
            return nil
        }
        
        guard let nsrange1 = result.first?.range(at: 1),
            let range1 = Range(nsrange1, in: string) else { return nil }
        guard let nsrange2 = result.first?.range(at: 2),
            let range2 = Range(nsrange2, in: string) else { return nil }

        return (String(string[range1]), String(string[range2]))
    }
}
