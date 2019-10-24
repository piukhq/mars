//
//  LoyaltyCardFullDetailsViewModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

protocol LoyaltyCardFullDetailsViewModelDelegate: class {
    func loyaltyCardFullDetailsViewModelDidFetchPaymentCards(_ loyaltyCardFullDetailsViewModel: LoyaltyCardFullDetailsViewModel, paymentCards: [PaymentCardModel])
}

class LoyaltyCardFullDetailsViewModel {
    private let router: MainScreenRouter
    private let repository: LoyaltyCardFullDetailsRepository
    let membershipCard: CD_MembershipCard
    weak var delegate: LoyaltyCardFullDetailsViewModelDelegate?

    init(membershipCard: CD_MembershipCard, repository: LoyaltyCardFullDetailsRepository, router: MainScreenRouter) {
        self.router = router
        self.repository = repository
        self.membershipCard = membershipCard
    }  

    var brandName: String {
        return membershipCard.membershipPlan?.account?.companyName ?? ""
    }

    var balance: CD_MembershipCardBalance? {
        return membershipCard.balances.allObjects.first as? CD_MembershipCardBalance
    }

    var pointsValueText: String {
        return "\(balance?.prefix ?? "")\(balance?.value?.stringValue ?? "") \(balance?.suffix ?? "")"
    }

    // MARK: - Public methods
    
    func getPaymentCards() {
        repository.getPaymentCards { [weak self] (results) in
            guard let wself = self else { return }
            wself.delegate?.loyaltyCardFullDetailsViewModelDidFetchPaymentCards(wself, paymentCards: results)
        }
    }
    
    func toBarcodeModel() {
        router.toBarcodeViewController(membershipCard: membershipCard) { }
    }
    
    func goToScreenForAction(action: BinkModuleView.BinkModuleAction) {
        switch action {
        case .login:
            //TODO: change to login screen after is implemented
            guard let membershipPlan = membershipCard.membershipPlan else { return }
            router.toAuthAndAddViewController(membershipPlan: membershipPlan, formPurpose: .otherLogin)
            break
        case .loginChanges:
            //TODO: change to login changes screen after is implemented
            guard let membershipPlan = membershipCard.membershipPlan else { return }
            router.toAuthAndAddViewController(membershipPlan: membershipPlan, formPurpose: .otherLogin)
            break
        case .transactions:
            if let transactions = membershipCard.formattedTransactions, !transactions.isEmpty {
                router.toTransactionsViewController(membershipCard: membershipCard)
            } else {
                let title = "transaction_history_unavailable_title".localized
                let description = String(format: "transaction_history_unavailable_description".localized, membershipCard.membershipPlan?.account?.planName ?? "")
                let attributedString = NSMutableAttributedString(string: title + "\n" + description)
                attributedString.addAttribute(.font, value: UIFont.headline, range: NSRange(location: 0, length: title.count))
                attributedString.addAttribute(.font, value: UIFont.bodyTextLarge, range: NSRange(location: title.count, length: description.count))
                
                let configuration = ReusableModalConfiguration(title: title, text: attributedString, showCloseButton: true)
                router.toReusableModalTemplateViewController(configurationModel: configuration)
            }
            break
        case .loginPending:
            let title = "log_in_pending_title".localized
            let description = "log_in_pending_description".localized
            router.toReusableModalTemplateViewController(configurationModel: getBasicReusableConfiguration(title: title, description: description))
//            router.toSimpleInfoViewController(pendingType: .login)
            break
        case .loginUnavailable:
            //TODO: change to login unavailable screen after is implemented
            router.displaySimplePopup(title: "error_title".localized, message: "to_be_implemented_message".localized)
            break
        case .signUp:
            //TODO: change to sign up screen after is implemented
            router.displaySimplePopup(title: "error_title".localized, message: "to_be_implemented_message".localized)
            break
        case .signUpPending:
            let title = "sign_up_pending_title".localized
            let description = "sign_up_pending_description".localized
            router.toReusableModalTemplateViewController(configurationModel: getBasicReusableConfiguration(title: title, description: description))
//            router.toSimpleInfoViewController(pendingType: .signup)
            break
        case .registerGhostCard:
            //TODO: change to sign up screen after is implemented
            router.displaySimplePopup(title: "error_title".localized, message: "to_be_implemented_message".localized)
            break
        case .registerGhostCardPending:
            let title = "sign_up_pending_title".localized
            let description = "sign_up_pending_description".localized
            router.toReusableModalTemplateViewController(configurationModel: getBasicReusableConfiguration(title: title, description: description))
//            router.toSimpleInfoViewController(pendingType: .register)
            break
        case .pllEmpty:
            router.toPllViewController(membershipCard: membershipCard)
            break
        case .pll:
            //TODO: change to PLL screen after is implemented
            router.displaySimplePopup(title: "error_title".localized, message: "to_be_implemented_message".localized)
            break
        case .unLinkable:
            let attributedString = NSMutableAttributedString(string: "unlinkable_pll_description".localized)
            
            toReusableModalTemplate(title: "unlinkable_pll_title".localized, description: attributedString)
            break
        case .genericError:
            let state = membershipCard.status?.status?.rawValue ?? ""
            
            var description = state + "\n"
            membershipCard.status?.formattedReasonCodes?.forEach {
                description += $0.value ?? ""
            }
    
            router.toReusableModalTemplateViewController(configurationModel: getBasicReusableConfiguration(title: "error_title".localized, description: description))
            break
        }
    }
    
    func getBasicReusableConfiguration(title: String, description: String) -> ReusableModalConfiguration {
        let attributedString = NSMutableAttributedString(string: title + "\n" + description)
        
        attributedString.addAttribute(.font, value: UIFont.headline, range: NSRange(location: 0, length: title.count))
        attributedString.addAttribute(.font, value: UIFont.bodyTextLarge, range: NSRange(location: title.count, length: description.count))
        
        return ReusableModalConfiguration(title: title, text: attributedString, showCloseButton: true)
    }
    
    func toReusableModalTemplate(title: String, description: NSMutableAttributedString) {
        let configurationModel = ReusableModalConfiguration(title: "", text: description, showCloseButton: true)
        
        router.toReusableModalTemplateViewController(configurationModel: configurationModel)
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
    
    func showDeleteConfirmationAlert(yesCompletion: @escaping () -> Void, noCompletion: @escaping () -> Void) {
        router.showDeleteConfirmationAlert(withMessage: "delete_card_confirmation".localized, yesCompletion: { [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.repository.deleteMembershipCard(id: strongSelf.membershipCard.id, onSuccess: { _ in
                yesCompletion()
            }, onError: { (error: Error) in
                strongSelf.router.displaySimplePopup(title: "error_title".localized, message: error.localizedDescription)
            })
        }, noCompletion: {
            noCompletion()
        })
    }
}
