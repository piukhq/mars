//
//  LoyaltyCardFullDetailsViewModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class LoyaltyCardFullDetailsViewModel {
    typealias EmptyCompletionBlock = () -> Void

    private let router: MainScreenRouter
    private let repository = LoyaltyCardFullDetailsRepository()
    private let informationRowFactory: PaymentCardDetailInformationRowFactory
    
    var paymentCards: [CD_PaymentCard]? {
        return Current.wallet.paymentCards
    }
    let membershipCard: CD_MembershipCard
    
    var aboutTitle: String {
        if let planName = membershipCard.membershipPlan?.account?.planName {
            return String(format: "about_membership_plan_title".localized, planName)
        } else {
            return "about_membership_title".localized
        }
    }
    
    var isMembershipCardAuthorised: Bool {
        return membershipCard.status?.status == .authorised
    }
    
    init(membershipCard: CD_MembershipCard, router: MainScreenRouter, informationRowFactory: PaymentCardDetailInformationRowFactory) {
        self.router = router
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
        router.toBarcodeViewController(membershipCard: membershipCard) { }
    }
    
    func goToScreenForAction(action: BinkModuleView.BinkModuleAction) {
        switch action {
        case .login:
            //TODO: change to login screen after is implemented
            guard let membershipPlan = membershipCard.membershipPlan else { return }
            router.toAuthAndAddViewController(membershipPlan: membershipPlan, formPurpose: .addFailed, existingMembershipCard: membershipCard)
            break
        case .loginChanges:
            //TODO: change to login changes screen after is implemented
            guard let membershipPlan = membershipCard.membershipPlan else { return }
            router.toAuthAndAddViewController(membershipPlan: membershipPlan, formPurpose: .addFailed, existingMembershipCard: membershipCard)
            break
        case .transactions:
            guard membershipCard.membershipPlan?.featureSet?.transactionsAvailable?.boolValue ?? false else {
                let title = "transaction_history_not_supported_title".localized
                let description = String(format: "transaction_history_not_supported_description".localized, membershipCard.membershipPlan?.account?.planName ?? "")
                let attributedTitle = NSMutableAttributedString(string: title + "\n", attributes: [.font: UIFont.headline])
                let attributedDescription = NSMutableAttributedString(string: description, attributes: [.font: UIFont.bodyTextLarge])
                let attributedString = NSMutableAttributedString()
                attributedString.append(attributedTitle)
                attributedString.append(attributedDescription)
                let configuration = ReusableModalConfiguration(title: title, text: attributedString, showCloseButton: true)
                router.toReusableModalTemplateViewController(configurationModel: configuration)
                return
            }
            router.toTransactionsViewController(membershipCard: membershipCard)
            break
        case .pending:
            let title = "generic_pending_module_title".localized
            let description = "generic_pending_module_description".localized
            router.toReusableModalTemplateViewController(configurationModel: getBasicReusableConfiguration(title: title, description: description))
            break
        case .loginUnavailable:
            let title = "transaction_history_not_supported_title".localized
            let description = String(format: "transaction_history_not_supported_description".localized, membershipCard.membershipPlan?.account?.planName ?? "")

            router.toReusableModalTemplateViewController(configurationModel: getBasicReusableConfiguration(title: title, description: description))
            break
        case .signUp:
            guard let membershipPlan = membershipCard.membershipPlan else { return }
            router.toSignUp(membershipPlan: membershipPlan, existingMembershipCard: membershipCard)
            break
        case .registerGhostCard:
            router.displaySimplePopup(title: "error_title".localized, message: "to_be_implemented_message".localized)
            break
        case .patchGhostCard:
            guard let membershipPlan = membershipCard.membershipPlan else { return }
            router.toPatchGhostCard(membershipPlan: membershipPlan, existingMembershipCard: membershipCard)
            break
        case .pllEmpty:
            router.toPllViewController(membershipCard: membershipCard, journey: .existingCard)
            break
        case .pll:
            router.toPllViewController(membershipCard: membershipCard, journey: .existingCard)
            break
        case .unLinkable:
            let title = "unlinkable_pll_title".localized
            let description = "unlinkable_pll_description".localized
            router.toReusableModalTemplateViewController(configurationModel: getBasicReusableConfiguration(title: title, description: description))
            break
        case .genericError:
            let state = membershipCard.status?.status?.rawValue ?? ""
            
            var description = state + "\n"
            membershipCard.status?.formattedReasonCodes?.forEach {
                description += $0.value ?? ""
            }
            
            router.toReusableModalTemplateViewController(configurationModel: getBasicReusableConfiguration(title: "error_title".localized, description: description))
            break
        case .aboutMembership:
            toAboutMembershipPlanScreen()
        case .noReasonCode:
            guard let membershipPlan = membershipCard.membershipPlan else { return }
            router.toAddOrJoinViewController(membershipPlan: membershipPlan, membershipCard: membershipCard)
        }
    }
    
    func getBasicReusableConfiguration(title: String, description: String) -> ReusableModalConfiguration {
        let attributedString = NSMutableAttributedString()
        let attributedTitle = NSAttributedString(string: title + "\n", attributes: [NSAttributedString.Key.font : UIFont.headline])
        let attributedBody = NSAttributedString(string: description, attributes: [NSAttributedString.Key.font : UIFont.bodyTextLarge])
        attributedString.append(attributedTitle)
        attributedString.append(attributedBody)
        
        return ReusableModalConfiguration(title: title, text: attributedString, showCloseButton: true)
    }
    
    func toReusableModalTemplate(title: String, description: NSMutableAttributedString) {
        let configurationModel = ReusableModalConfiguration(title: "", text: description, showCloseButton: true)
        
        router.toReusableModalTemplateViewController(configurationModel: configurationModel)
    }
    
    func toRewardsHistoryScreen() {
        router.toRewardsHistoryViewController(membershipCard: membershipCard)
    }
    
    func toAboutMembershipPlanScreen() {
        let config = getBasicReusableConfiguration(title: aboutTitle, description: membershipCard.membershipPlan?.account?.planDescription ?? "")
        router.toReusableModalTemplateViewController(configurationModel: config)
    }
    
    func toSecurityAndPrivacyScreen() {
        router.toPrivacyAndSecurityViewController()
    }
    
    func popToRootController() {
        router.popToRootViewController()
    }
    
    @objc func popViewController() {
        router.popViewController()
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
        router.toVoucherDetailViewController(voucher: voucher, plan: plan)
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
    
    func showDeleteConfirmationAlert(yesCompletion: EmptyCompletionBlock? = nil, noCompletion: EmptyCompletionBlock? = nil) {
        router.showDeleteConfirmationAlert(withMessage: "delete_card_confirmation".localized, yesCompletion: { [weak self] in
            guard let self = self else { return }
            guard Current.apiClient.networkIsReachable else {
                self.router.presentNoConnectivityPopup()
                noCompletion?()
                return
            }
            self.repository.delete(self.membershipCard) {
                Current.wallet.refreshLocal()
                self.router.popToRootViewController()
                yesCompletion?()
            }
        }, noCompletion: {
            DispatchQueue.main.async {
                noCompletion?()
            }
        })
    }
}
