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
    
    init(membershipCard: CD_MembershipCard, informationRowFactory: WalletCardDetailInformationRowFactory) {
        self.membershipCard = membershipCard
        self.informationRowFactory = informationRowFactory
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
        if membershipCard.membershipPlan?.isPLR == true {
            guard let voucher = membershipCard.activeVouchers?.first else { return nil }
            return voucher.balanceString
        }
        
        return "\(balance?.prefix ?? "")\(balance?.value?.stringValue ?? "") \(balance?.suffix ?? "")"
    }
    
    var shouldShowOfferTiles: Bool {
        // If there are no images, there are no offer tiles! Return early
        guard let planImages = membershipCard.membershipPlan?.imagesSet else { return false }
        return planImages.filter({ $0.type?.intValue == 2}).count != 0
    }
    
    var brandHeaderAspectRatio: CGFloat {
        return LayoutHelper.LoyaltyCardDetail.brandHeaderAspectRatio(forMembershipCard: membershipCard)
    }
    
    // MARK: - Public methods
    
    func toBarcodeModel() {
        let viewController = ViewControllerFactory.makeBarcodeViewController(membershipCard: membershipCard)
        let navigationRequest = ModalNavigationRequest(viewController: viewController)
        Current.navigate.to(navigationRequest)
    }
    
    func goToScreenForAction(action: BinkModuleView.BinkModuleAction) {
        switch action {
        case .login, .loginChanges:
            guard let membershipPlan = membershipCard.membershipPlan else { return }
            let viewController = ViewControllerFactory.makeAuthAndAddViewController(membershipPlan: membershipPlan, formPurpose: .addFailed, existingMembershipCard: membershipCard)
            let navigationRequest = ModalNavigationRequest(viewController: viewController)
            Current.navigate.to(navigationRequest)
        case .transactions:
            guard membershipCard.membershipPlan?.featureSet?.transactionsAvailable?.boolValue ?? false else {
                let title = "transaction_history_not_supported_title".localized
                let description = String(format: "transaction_history_not_supported_description".localized, membershipCard.membershipPlan?.account?.planName ?? "")
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
            let title = "generic_pending_module_title".localized
            let description = "generic_pending_module_description".localized
            let attributedString = ReusableModalConfiguration.makeAttributedString(title: title, description: description)
            let configuration = ReusableModalConfiguration(text: attributedString)
            let viewController = ViewControllerFactory.makeReusableTemplateViewController(configuration: configuration)
            let navigationRequest = ModalNavigationRequest(viewController: viewController)
            Current.navigate.to(navigationRequest)
        case .loginUnavailable:
            let title = "transaction_history_not_supported_title".localized
            let description = String(format: "transaction_history_not_supported_description".localized, membershipCard.membershipPlan?.account?.planName ?? "")
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
            let alert = ViewControllerFactory.makeOkAlertViewController(title: "error_title".localized, message: "to_be_implemented_message".localized)
            Current.navigate.to(AlertNavigationRequest(alertController: alert))
        case .patchGhostCard:
            guard let membershipPlan = membershipCard.membershipPlan else { return }
            let viewController = ViewControllerFactory.makePatchGhostCardViewController(membershipPlan: membershipPlan, existingMembershipCard: membershipCard)
            let navigationRequest = ModalNavigationRequest(viewController: viewController)
            Current.navigate.to(navigationRequest)
        case .pll, .pllEmpty:
            let viewController = ViewControllerFactory.makePllViewController(membershipCard: membershipCard, journey: .existingCard)
            let navigationRequest = ModalNavigationRequest(viewController: viewController, allowDismiss: false)
            Current.navigate.to(navigationRequest)
        case .unLinkable:
            let title = "unlinkable_pll_title".localized
            let description = "unlinkable_pll_description".localized
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

            let attributedString = ReusableModalConfiguration.makeAttributedString(title: "error_title".localized, description: description)
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
        let title: String = "security_and_privacy_title".localized
        let description: String = "security_and_privacy_description".localized
        let configuration = ReusableModalConfiguration(title: title, text: ReusableModalConfiguration.makeAttributedString(title: title, description: description))
        let viewController = ViewControllerFactory.makeSecurityAndPrivacyViewController(configuration: configuration)
        let navigationRequest = ModalNavigationRequest(viewController: viewController)
        Current.navigate.to(navigationRequest)
    }
    
    func getOfferTileImageUrls() -> [String]? {
        let planImages = membershipCard.membershipPlan?.imagesSet
        return planImages?.filter({ $0.type?.intValue == 2}).compactMap { $0.url }
    }
    
    // MARK: PLR

    
    var shouldShouldPLR: Bool {
        return membershipCard.membershipPlan?.isPLR ?? false && membershipCard.vouchers.count != 0
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
        let alert = ViewControllerFactory.makeDeleteConfirmationAlertController(message: "delete_card_confirmation".localized, deleteAction: { [weak self] in
            guard let self = self else { return }
            guard Current.apiClient.networkIsReachable else {
                let alert = ViewControllerFactory.makeNoConnectivityAlertController()
                let navigationRequest = AlertNavigationRequest(alertController: alert)
                Current.navigate.to(navigationRequest)
                return
            }
            self.repository.delete(self.membershipCard) {
                Current.wallet.refreshLocal()
                Current.navigate.back()
            }
        })
        let navigationRequest = AlertNavigationRequest(alertController: alert)
        Current.navigate.to(navigationRequest)
    }
}
