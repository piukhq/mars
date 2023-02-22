//
//  LoyaltyCardFullDetailsViewModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit
import SwiftUI
import FirebaseStorage

class LoyaltyCardFullDetailsViewModel {
    typealias EmptyCompletionBlock = () -> Void

    private let repository = LoyaltyCardFullDetailsRepository()
    private let informationRowFactory: WalletCardDetailInformationRowFactory
    
    var informationRows: [CardDetailInformationRow]
    
    var paymentCards: [CD_PaymentCard]? {
        return Current.wallet.paymentCards
    }
    var membershipCard: CD_MembershipCard
    
    var isMembershipCardAuthorised: Bool {
        return membershipCard.status?.status == .authorised
    }
    
    var isMembershipCardPLL: Bool {
        return membershipCard.membershipPlan?.isPLL ?? false
    }
    
    let barcodeViewModel: BarcodeViewModel
    
    private let animated: Bool
    
    init(membershipCard: CD_MembershipCard, informationRowFactory: WalletCardDetailInformationRowFactory, animated: Bool = true) {
        self.membershipCard = membershipCard
        self.informationRowFactory = informationRowFactory
        self.barcodeViewModel = BarcodeViewModel(membershipCard: membershipCard)
        self.animated = animated
        self.informationRows = informationRowFactory.makeLoyaltyInformationRows(membershipCard: membershipCard)
    }
    
    var brandName: String {
        return membershipCard.card?.merchantName ?? membershipCard.membershipPlan?.account?.companyName ?? ""
    }
    
    var brandNameForGeoData: String {
        let formatted = membershipCard.membershipPlan?.account?.companyName?.replacingOccurrences(of: " ", with: "-")
        return formatted?.lowercased() ?? ""
    }
    
    var balance: CD_MembershipCardBalance? {
        return membershipCard.balances.allObjects.first as? CD_MembershipCardBalance
    }
    
    var pointsValueText: String? {
        // Only authed cards will have a balance
        guard membershipCard.status?.status == .authorised else {
            return nil
        }
        
        // PLR
        if membershipCard.membershipPlan?.isPLR == true && membershipCard.status?.status == .authorised {
            guard let voucher = membershipCard.activeVouchers?.first(where: {
                let state = VoucherState(rawValue: $0.state ?? "")
                return state == .inProgress
            }) else { return nil }
            return voucher.balanceString
        }
        
        return "\(balance?.prefix ?? "")\(balance?.value?.stringValue ?? "") \(balance?.suffix ?? "")"
    }
    
    var shouldShowOfferTiles: Bool {
        // If there are no images, there are no offer tiles! Return early
        guard let planImages = membershipCard.membershipPlan?.imagesSet else { return false }
        return !planImages.filter({ $0.type?.intValue == 2 }).isEmpty
    }
    
    var brandHeaderAspectRatio: CGFloat {
        return LayoutHelper.LoyaltyCardDetail.brandHeaderAspectRatio(forMembershipCard: membershipCard)
    }
    
    var cardColor: UIColor? {
        if let hexColor = membershipCard.card?.colour {
            return UIColor(hexString: hexColor)
        } else {
            return secondaryColor
        }
    }
    
    var secondaryColor: UIColor? {
        if let customColor = membershipCard.card?.secondaryColour {
            return UIColor(hexString: customColor)
        } else {
            return membershipCard.membershipPlan?.secondaryBrandColor
        }
    }
    
    var secondaryColourIsDark: Bool {
        return !(secondaryColor?.isLight() ?? false)
    }
    
    var shouldShowBarcode: Bool {
        return !(membershipCard.membershipPlan?.featureSet?.planCardType == .link) && barcodeViewModel.isBarcodeAvailable && barcodeViewModel.barcodeImage(withSize: .zero) != nil
    }
    
    var shouldShowBarcodeButton: Bool {
        return membershipCard.card?.barcode != nil || membershipCard.card?.membershipId != nil
    }
    
    var shouldAnimateContent: Bool {
        return animated
    }
    
    var barcodeButtonTitle: String {
        var buttonTitle = L10n.detailsHeaderShowCardNumber
        
        if shouldShowBarcode {
            switch barcodeViewModel.barcodeType {
            case .qr:
                buttonTitle = L10n.detailsHeaderShowQrCode
            case .aztec:
                buttonTitle = L10n.detailsHeaderShowAztecCode
            default:
                buttonTitle = L10n.detailsHeaderShowBarcode
            }
        }

        return buttonTitle
    }
    
    var indexToInsertVoucherCell: Int {
        return shouldShowBarcodeButton ? 4 : 3
    }
    
    var cardIsCustomCard: Bool {
        return membershipCard.membershipPlan?.isCustomCard ?? false
    }
    
    var planUrl: String? {
        return membershipCard.membershipPlan?.account?.planURL
    }
        
    // MARK: - Public methods
    
    func storeOpenedTimeForCard() {
        Current.database.performBackgroundTask(with: membershipCard) { (backgroundContext, safeObject) in
            guard let card = safeObject else {
                fatalError("We should never get here. Core data didn't return us an object, why not?")
            }
            
            card.openedTime = Date()
            
            do {
                try backgroundContext.save()
            } catch {
                print("Failed to save")
            }
        }
    }
    
    func fetchGeoData(completion: @escaping (Bool, Bool) -> Void) {
        if Current.featureManager.isFeatureEnabled(.locations, merchant: brandNameForGeoData) {
            let companyName = brandNameForGeoData
            if !companyName.isBlank {
                let fileName = "\(companyName).geojson"
                if let _ = Cache.geoLocationsDataCache.object(forKey: fileName.toNSString()) {
                    completion(true, false)
                    return
                }
                
                let storage = Storage.storage()
                let pathReference = storage.reference(withPath: "locations/\(fileName)")
                
                pathReference.getData(maxSize: 4 * 1024 * 1024) { data, _ in
                    guard let data = data else {
                        completion(false, false)
                        return
                    }
                    
                    Cache.geoLocationsDataCache.setObject(DataCache(data: data as NSData), forKey: fileName.toNSString())
                    completion(true, true)
                }
            }
        }
    }
    
    func toBarcodeModel() {
        let viewController = ViewControllerFactory.makeBarcodeViewController(membershipCard: membershipCard)
        let navigationRequest = ModalNavigationRequest(viewController: viewController)
        Current.navigate.to(navigationRequest)
        MixpanelUtility.track(.viewBarcode(brandName: membershipCard.membershipPlan?.account?.companyName ?? "Unknown", route: .lcd))
    }
    
    func toGeoLocations() {
        let companyName = membershipCard.membershipPlan?.account?.companyName ?? "Unknown"
        let viewController = ViewControllerFactory.makeGeoLocationsViewController(companyName: companyName)
        let navigationRequest = ModalNavigationRequest(viewController: viewController)
        Current.navigate.to(navigationRequest)
        MixpanelUtility.track(.toLocations(brandName: companyName))
    }
    
    func goToScreenForState(state: ModuleState, delegate: LoyaltyCardFullDetailsModalDelegate? = nil) {
        switch state {
        case .loginChanges, .lpcLoginRequired:
            guard let membershipPlan = membershipCard.membershipPlan else { return }
            let cardNumberPrefilledValue = FormDataSource.PrefilledValue(commonName: .cardNumber, value: membershipCard.card?.membershipId)
            let viewController = ViewControllerFactory.makeAuthAndAddViewController(membershipPlan: membershipPlan, formPurpose: .addFailed, existingMembershipCard: membershipCard, prefilledFormValues: [cardNumberPrefilledValue])
            let navigationRequest = ModalNavigationRequest(viewController: viewController)
            Current.navigate.to(navigationRequest)
        case .plrTransactions, .pllTransactions:
            guard membershipCard.membershipPlan?.featureSet?.transactionsAvailable?.boolValue ?? false else {
                let title = L10n.transactionHistoryNotSupportedTitle
                let description = L10n.transactionHistoryNotSupportedDescription(membershipCard.membershipPlan?.account?.planName ?? "")
                let attributedTitle = NSMutableAttributedString(string: title + "\n", attributes: [.font: UIFont.headline])
                let attributedDescription = NSMutableAttributedString(string: description, attributes: [.font: UIFont.bodyTextLarge])
                let attributedString = NSMutableAttributedString()
                attributedString.append(attributedTitle)
                attributedString.append(attributedDescription)
                
                let configuration = ReusableModalConfiguration(title: title, text: attributedString)
                let viewController = ViewControllerFactory.makeReusableTemplateViewController(configuration: configuration)
                let navigationRequest = ModalNavigationRequest(viewController: viewController)
                Current.navigate.to(navigationRequest)
                return
            }
            let viewController = ViewControllerFactory.makeTransactionsViewController(membershipCard: membershipCard)
            let navigationRequest = ModalNavigationRequest(viewController: viewController)
            Current.navigate.to(navigationRequest)
        case .pending:
            if let planId = membershipCard.membershipPlan?.id, Current.pointsScrapingManager.planIdIsWebScrapable(Int(planId)) {
                Current.pointsScrapingManager.debug()
                return
            }
            
            let title = L10n.genericPendingModuleTitle
            let description = L10n.genericPendingModuleDescription
            let attributedString = ReusableModalConfiguration.makeAttributedString(title: title, description: description)
            let configuration = ReusableModalConfiguration(text: attributedString)
            let viewController = ViewControllerFactory.makeReusableTemplateViewController(configuration: configuration)
            let navigationRequest = ModalNavigationRequest(viewController: viewController)
            Current.navigate.to(navigationRequest)
        case .loginUnavailable:
            let title = L10n.transactionHistoryNotSupportedTitle
            let description = L10n.transactionHistoryNotSupportedDescription(membershipCard.membershipPlan?.account?.planName ?? "")
            let attributedString = ReusableModalConfiguration.makeAttributedString(title: title, description: description)
            let configuration = ReusableModalConfiguration(text: attributedString)
            let viewController = ViewControllerFactory.makeReusableTemplateViewController(configuration: configuration)
            let navigationRequest = ModalNavigationRequest(viewController: viewController)
            Current.navigate.to(navigationRequest)
        case .signUp:
            guard let membershipPlan = membershipCard.membershipPlan else { return }
            let viewController = ViewControllerFactory.makeSignUpViewController(membershipPlan: membershipPlan, existingMembershipCard: membershipCard)
            let navigationRequest = ModalNavigationRequest(viewController: viewController)
            Current.navigate.to(navigationRequest)
        case .registerGhostCard:
            let alert = ViewControllerFactory.makeOkAlertViewController(title: L10n.errorTitle, message: L10n.toBeImplementedMessage)
            Current.navigate.to(AlertNavigationRequest(alertController: alert))
        case .patchGhostCard:
            guard let membershipPlan = membershipCard.membershipPlan else { return }
            let viewController = ViewControllerFactory.makePatchGhostCardViewController(membershipPlan: membershipPlan, existingMembershipCard: membershipCard)
            let navigationRequest = ModalNavigationRequest(viewController: viewController)
            Current.navigate.to(navigationRequest)
        case .pll, .pllNoPaymentCards, .pllError:
            let viewController = ViewControllerFactory.makePllViewController(membershipCard: membershipCard, journey: .existingCard, delegate: delegate)
            let navigationRequest = ModalNavigationRequest(viewController: viewController, dragToDismiss: state == .pllNoPaymentCards)
            Current.navigate.to(navigationRequest)
        case .unlinkable:
            let title = L10n.unlinkablePllTitle
            let description = L10n.unlinkablePllDescription
            let attributedString = ReusableModalConfiguration.makeAttributedString(title: title, description: description)
            let configuration = ReusableModalConfiguration(text: attributedString)
            let viewController = ViewControllerFactory.makeReusableTemplateViewController(configuration: configuration)
            let navigationRequest = ModalNavigationRequest(viewController: viewController)
            Current.navigate.to(navigationRequest)
        case .genericError:
            let state = membershipCard.status?.status?.rawValue ?? ""

            var description = state + "\n"
            membershipCard.status?.formattedReasonCodes?.forEach {
                description += $0.description
            }

            let attributedString = ReusableModalConfiguration.makeAttributedString(title: L10n.errorTitle, description: description)
            let configuration = ReusableModalConfiguration(text: attributedString)
            let viewController = ViewControllerFactory.makeReusableTemplateViewController(configuration: configuration)
            let navigationRequest = ModalNavigationRequest(viewController: viewController)
            Current.navigate.to(navigationRequest)
        case .aboutMembership:
            toAboutMembershipPlanScreen()
        case .noReasonCode:
            guard let membershipPlan = membershipCard.membershipPlan else { return }
            let viewController = ViewControllerFactory.makeAddOrJoinViewController(membershipPlan: membershipPlan, membershipCard: membershipCard)
            let navigationRequest = ModalNavigationRequest(viewController: viewController)
            Current.navigate.to(navigationRequest)
        case .lpcBalance(_, let lastCheckedDate):
            let viewController = ViewControllerFactory.makeLocalPointsCollectionBalanceRefreshViewController(membershipCard: membershipCard, lastCheckedDate: lastCheckedDate)
            let navigationRequest = ModalNavigationRequest(viewController: viewController)
            Current.navigate.to(navigationRequest)
        }
    }
    
    func toRewardsHistoryScreen() {
        let viewController = ViewControllerFactory.makeRewardsHistoryViewController(membershipCard: membershipCard)
        let navigationRequest = PushNavigationRequest(viewController: viewController)
        Current.navigate.to(navigationRequest)
    }
    
    func toAboutMembershipPlanScreen() {
        guard let plan = membershipCard.membershipPlan else { return }
        let viewController = ViewControllerFactory.makeAboutMembershipPlanViewController(membershipPlan: plan)
        let navigationRequest = ModalNavigationRequest(viewController: viewController)
        Current.navigate.to(navigationRequest)
    }
    
    func toSecurityAndPrivacyScreen() {
        let hostingViewController = UIHostingController(rootView: ReusableTemplateView(title: L10n.securityAndPrivacyTitle, description: L10n.securityAndPrivacyDescription))
        let navigationRequest = ModalNavigationRequest(viewController: hostingViewController)
        Current.navigate.to(navigationRequest)
    }

    var offerTileImages: [CD_MembershipPlanImage]? {
        return membershipCard.membershipPlan?.imagesSet?.filter({ $0.type?.intValue == 2 })
    }
    
    // MARK: PLR

    var shouldShowPLR: Bool {
        return membershipCard.membershipPlan?.isPLR ?? false && !membershipCard.vouchers.isEmpty
    }
    
    var activeVouchersCount: Int {
        return membershipCard.activeVouchers?.count ?? 0
    }
    
    var vouchers: [CD_Voucher]? {
        return membershipCard.activeVouchers
    }
    
    func toVoucherDetailScreen(voucher: CD_Voucher) {
        guard let plan = membershipCard.membershipPlan else {
            fatalError("Membership card has no membership plan attributed to it. This should never be the case.")
        }
        let viewController = ViewControllerFactory.makeVoucherDetailViewController(voucher: voucher, plan: plan)
        let navigationRequest = PushNavigationRequest(viewController: viewController)
        Current.navigate.to(navigationRequest)
    }
    
    func state(forVoucher voucher: CD_Voucher) -> VoucherState? {
        return VoucherState(rawValue: voucher.state ?? "")
    }
}

extension LoyaltyCardFullDetailsViewModel {
    func showDeleteConfirmationAlert() {
        guard membershipCard.status?.status != .pending else {
            let alert = ViewControllerFactory.makeOkAlertViewController(title: L10n.alertViewCannotDeleteCardTitle, message: L10n.alertViewCannotDeleteCardBody)
            let navigationRequest = AlertNavigationRequest(alertController: alert)
            Current.navigate.to(navigationRequest)
            return
        }
        
        let alert = ViewControllerFactory.makeDeleteConfirmationAlertController(message: L10n.deleteCardConfirmation, deleteAction: { [weak self] in
            guard let self = self else { return }
            guard Current.apiClient.networkIsReachable else {
                let alert = ViewControllerFactory.makeNoConnectivityAlertController()
                let navigationRequest = AlertNavigationRequest(alertController: alert)
                Current.navigate.to(navigationRequest)
                return
            }
            MixpanelUtility.track(.loyaltyCardDeleted(brandName: self.brandName, route: .lcd))
            
            self.repository.delete(self.membershipCard) {
                BinkLogger.infoPrivateHash(event: LoyaltyCardLoggerEvent.loyaltyCardDeleted, value: self.membershipCard.id)
                Current.wallet.refreshLocal()
                Current.navigate.back()
            }
        })
        let navigationRequest = AlertNavigationRequest(alertController: alert)
        Current.navigate.to(navigationRequest)
    }
}
