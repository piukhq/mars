//
//  LoyaltyCardFullDetailsViewModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class LoyaltyCardFullDetailsViewModel {
    typealias EmptyCompletionBlock = () -> Void

    private let repository = LoyaltyCardFullDetailsRepository()
    private let informationRowFactory: WalletCardDetailInformationRowFactory
    
    var paymentCards: [CD_PaymentCard]? {
        return Current.wallet.paymentCards
    }
    let membershipCard: CD_MembershipCard
    
    var isMembershipCardAuthorised: Bool {
        return membershipCard.status?.status == .authorised
    }
    
    let barcodeViewModel: BarcodeViewModel
    
    private let animated: Bool
    
    init(membershipCard: CD_MembershipCard, informationRowFactory: WalletCardDetailInformationRowFactory, animated: Bool = true) {
        self.membershipCard = membershipCard
        self.informationRowFactory = informationRowFactory
        self.barcodeViewModel = BarcodeViewModel(membershipCard: membershipCard)
        self.animated = animated
    }
    
    var brandName: String {
        return membershipCard.membershipPlan?.account?.companyName ?? ""
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
    
    var secondaryColor: UIColor? {
        return membershipCard.membershipPlan?.secondaryBrandColor
    }
    
    var secondaryColourIsDark: Bool {
        return !(secondaryColor?.isLight() ?? false)
    }
    
    var shouldShowBarcode: Bool {
        return !(membershipCard.membershipPlan?.featureSet?.planCardType == .link) && barcodeViewModel.isBarcodeAvailable && barcodeViewModel.barcodeImage(withSize: .zero) != nil
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
        
    // MARK: - Public methods
    
    func toBarcodeModel() {
        let viewController = ViewControllerFactory.makeBarcodeViewController(membershipCard: membershipCard)
        let navigationRequest = ModalNavigationRequest(viewController: viewController)
        Current.navigate.to(navigationRequest)
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
        let title: String = L10n.securityAndPrivacyTitle
        let description: String = L10n.securityAndPrivacyDescription
        let configuration = ReusableModalConfiguration(title: title, text: ReusableModalConfiguration.makeAttributedString(title: title, description: description))
        let viewController = ViewControllerFactory.makeSecurityAndPrivacyViewController(configuration: configuration)
        let navigationRequest = ModalNavigationRequest(viewController: viewController)
        Current.navigate.to(navigationRequest)
    }

    var offerTileImages: [CD_MembershipPlanImage]? {
        return membershipCard.membershipPlan?.imagesSet?.filter({ $0.type?.intValue == 2 })
    }
    
    // MARK: PLR

    
    var shouldShouldPLR: Bool {
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

// MARK: Information rows

extension LoyaltyCardFullDetailsViewModel {
    var informationRows: [CardDetailInformationRow] {
        return informationRowFactory.makeLoyaltyInformationRows(membershipCard: membershipCard)
    }
    
    func informationRow(forIndexPath indexPath: IndexPath) -> CardDetailInformationRow {
        return informationRows[indexPath.row]
    }
    
    func performActionForInformationRow(atIndexPath indexPath: IndexPath) {
        informationRows[indexPath.row].action()
    }
    
    func showDeleteConfirmationAlert() {
        let alert = ViewControllerFactory.makeDeleteConfirmationAlertController(message: L10n.deleteCardConfirmation, deleteAction: { [weak self] in
            guard let self = self else { return }
            guard Current.apiClient.networkIsReachable else {
                let alert = ViewControllerFactory.makeNoConnectivityAlertController()
                let navigationRequest = AlertNavigationRequest(alertController: alert)
                Current.navigate.to(navigationRequest)
                return
            }
            self.repository.delete(self.membershipCard) {
                if #available(iOS 14.0, *) {
                    BinkLogger.infoPrivateHash(event: LoyaltyCardLoggerEvent.loyaltyCardDeleted, value: self.membershipCard.id)
                }
                
                Current.wallet.refreshLocal()
                Current.navigate.back()
            }
        })
        let navigationRequest = AlertNavigationRequest(alertController: alert)
        Current.navigate.to(navigationRequest)
    }
}
