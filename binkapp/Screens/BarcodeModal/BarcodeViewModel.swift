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
        return BarcodeImageHelper.barcodeType(membershipCard: membershipCard)
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
        return BarcodeImageHelper.barcodeImage(membershipCard: membershipCard, withSize: size, alwaysShowBarCode: alwaysShowBarCode)
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
