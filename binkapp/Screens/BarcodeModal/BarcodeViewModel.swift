//
//  BarcodeViewModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit
import ZXingObjC

enum BarcodeUse {
    case loyaltyCard
    case coupon
}

enum MerchantImageType {
    case icon
    case hero
}

enum BarcodeType: Int {
    case code128
    case qr
    case aztec
    case pdf417
    case ean13
    case dataMatrix
    case itf
    case code39
    
    var zxingType: ZXBarcodeFormat {
        switch self {
        case .code128:
            return kBarcodeFormatCode128
        case .qr:
            return kBarcodeFormatQRCode
        case .aztec:
            return kBarcodeFormatAztec
        case .pdf417:
            return kBarcodeFormatPDF417
        case .ean13:
            return kBarcodeFormatEan13
        case .dataMatrix:
            return kBarcodeFormatDataMatrix
        case .itf:
            return kBarcodeFormatITF
        case .code39:
            return kBarcodeFormatCode39
        }
    }
    
    /// Code 39 barcodes draw at a fixed width [in the ZXing library](https://github.com/zxing/zxing/blob/723b65fe3dc65b88d26efa4c65e4217234a06ef0/core/src/main/java/com/google/zxing/oned/Code39Writer.java#L59).
    func preferredWidth(for length: Int, targetWidth: CGFloat) -> CGFloat {
        switch self {
        case .code39:
            let baseWidth = CGFloat(24 + 1 + (13 * length))
            let codeWidth = baseWidth * ceil(targetWidth / baseWidth)
            return codeWidth
        default:
            return 1
        }
    }
}

class BarcodeViewModel: ObservableObject {
    let membershipCard: CD_MembershipCard
    var imageType: MerchantImageType = .hero
    var barcodeUse: BarcodeUse = .loyaltyCard
    var screenBrightness: CGFloat
    static let alwaysShowBarcodePreferencesSlug = "show-barcode-always"

    @Published var merchantImage: Image?
    @Published var showingReportIssueOptions = false {
        didSet {
            reportIssueButton.viewModel.isLoading = false
        }
    }
    
    @Published var alwaysShowBarcode = false
    
    lazy var reportIssueButton: BinkButtonSwiftUIView = {
        return BinkButtonSwiftUIView(viewModel: ButtonViewModel(title: L10n.barcodeReportIssueButtonTitle), enabled: true, buttonTapped: { [weak self] in
            self?.showingReportIssueOptions = true
        }, type: .plain)
    }()

    
    // MARK: - Computed properties

    var barcodeImageIsRenderable: Bool {
        return barcodeImage(withSize: CGSize(width: 100, height: 100)) != nil
    }
    
    var title: String {
        return membershipCard.card?.merchantName ?? membershipCard.membershipPlan?.account?.companyName ?? ""
    }
    
    var descriptionText: String {
        switch barcodeUse {
        case .loyaltyCard:
            if barcodeImageIsRenderable {
                return L10n.barcodeCardDescription
            } else {
                return L10n.barcodeCardNumberDescription
            }
        case .coupon:
            return L10n.barcodeCouponDescription
        }
    }
    
    var membershipNumberTitle: String {
        switch membershipCard.membershipPlan?.isCustomCard {
        case false:
            return L10n.barcodeMembershipNumberTitle(membershipCard.membershipPlan?.account?.planNameCard ?? "")
        default:
            return L10n.barcodeViewTitle
        }
    }
    
    var isBarcodeAvailable: Bool {
        return membershipCard.card?.barcode != nil
    }
    
    var isCardNumberAvailable: Bool {
        return cardNumber != nil
    }
    
    var cardNumber: String? {
        return membershipCard.card?.membershipId
    }
    
    var barcodeNumber: String {
        return membershipCard.card?.barcode ?? ""
    }
    
    var barcodeMatchesMembershipNumber: Bool {
        return cardNumber == barcodeNumber
    }
    
    var shouldShowbarcodeNumber: Bool {
        return !barcodeMatchesMembershipNumber && isBarcodeAvailable
    }
    
    var barcodeType: BarcodeType {
        guard let barcodeType = membershipCard.card?.barcodeType?.intValue else {
            return .code128
        }
        return BarcodeType(rawValue: barcodeType) ?? .code128
    }
    
    
    // MARK: Init

    init(membershipCard: CD_MembershipCard) {
        self.screenBrightness = UIScreen.main.brightness
        self.membershipCard = membershipCard
        self.setShouldAlwaysDisplayBarCode()
    }
    
    var barcodeIsMoreSquareThanRectangle: Bool {
        let image = barcodeImage(withSize: CGSize(width: 100, height: 100), drawInContainer: false)
        if let size = image?.size {
            return size.width - size.height < 20
        }
        return false
    }
    
    
    // MARK: - Functions

    func barcodeImage(withSize size: CGSize, drawInContainer: Bool = true, alwaysShowBarCode: Bool = false) -> UIImage? {
        guard let barcodeString = alwaysShowBarCode ? (membershipCard.card?.barcode ?? self.cardNumber) : membershipCard.card?.barcode else { return nil }
        
        let writer = ZXMultiFormatWriter()
        let encodeHints = ZXEncodeHints()
        encodeHints.margin = 0
        
        
        let width = self.barcodeType == .code39 ? self.barcodeType.preferredWidth(for: barcodeString.count, targetWidth: size.width) : size.width
        let height = size.height
        var image: UIImage?
        
        let exception = tryBlock { [weak self] in
            guard let self = self else { return }
            
            let result = try? writer.encode(barcodeString, format: self.barcodeType.zxingType, width: Int32(width), height: Int32(height), hints: encodeHints)
            
            guard let cgImage = ZXImage(matrix: result).cgimage else { return }
            
            // If the resulting image is larger than the destination, draw the CGImage in a fixed container
            if CGFloat(cgImage.width) > size.width && drawInContainer {
                let renderer = UIGraphicsImageRenderer(size: size)
                let img = renderer.image { ctx in
                    ctx.cgContext.draw(cgImage, in: CGRect(origin: .zero, size: size))
                }

                image = img
            } else {
                image = UIImage(cgImage: cgImage)
            }
        }
        
        return exception == nil ? image : nil
    }
    
    func getMerchantImage(colorScheme: ColorScheme) {
        if let plan = membershipCard.membershipPlan {
            ImageService.getImage(forPathType: .membershipPlanAlternativeHero(plan: plan), userInterfaceStyle: colorScheme.userInterfaceStyle()) { [weak self] retrievedImage in
                if let retrievedImage = retrievedImage {
                    self?.merchantImage = Image(uiImage: retrievedImage)
                    self?.imageType = .hero
                } else {
                    ImageService.getImage(forPathType: .membershipPlanIcon(plan: plan), userInterfaceStyle: colorScheme.userInterfaceStyle()) { retrievedImage in
                        /// If we can't retrieve the hero image, adjust aspect ratio and use square icon
                        if let retrievedImage = retrievedImage {
                            self?.merchantImage = Image(uiImage: retrievedImage)
                            self?.imageType = .icon
                        }
                    }
                }
            }
        }
    }
    
    func heightForHighVisView(text: String) -> CGFloat {
        let rowCount = text.splitStringIntoArray(elementLength: 8).count
        let widthOfStackView = UIScreen.main.bounds.width - (BarcodeScreenSwiftUIView.Constants.horizontalInset * 2)
        let boxWidth = widthOfStackView / 8
        let boxHeight = boxWidth * 1.8
        return boxHeight * CGFloat(rowCount)
    }
    
    func setShouldAlwaysDisplayBarCode() {
        if Current.userDefaults.value(forDefaultsKey: .showBarcodeAlways) == nil {
            alwaysShowBarcode = false
            return
        }
        
        alwaysShowBarcode = Current.userDefaults.bool(forDefaultsKey: .showBarcodeAlways)
    }
    
    func setShowBarcodeAlwaysPreference(preferencesRepository: PreferencesProtocol?) {
        if let preferences = preferencesRepository {
            let checkedState = "1"
            let dictionary = [BarcodeViewModel.alwaysShowBarcodePreferencesSlug: checkedState]
            
            preferences.putPreferences(preferences: dictionary) {
                if !UIApplication.isRunningUnitTests {
                    MessageView.show(L10n.preferencesUpdated, type: .snackbar(.short))
                    MixpanelUtility.setUserProperty(.showBarcodeAlways(true))
                }
                
                Current.userDefaults.set(true, forDefaultsKey: .showBarcodeAlways)
                self.setShouldAlwaysDisplayBarCode()
            } onError: { _ in
            }
        }
    }
}

extension ColorScheme {
    func userInterfaceStyle() -> UIUserInterfaceStyle {
        switch self {
        case .dark:
            return .dark
        case .light:
            return .light
        @unknown default:
            return .light
        }
    }
}
