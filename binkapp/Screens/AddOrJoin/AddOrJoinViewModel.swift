//
//  AddOrJoinViewModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class AddOrJoinViewModel {
    private let membershipPlan: CD_MembershipPlan
    private let membershipCard: CD_MembershipCard?
    private let router: MainScreenRouter
    
    init(membershipPlan: CD_MembershipPlan, membershipCard: CD_MembershipCard? = nil, router: MainScreenRouter) {
        self.membershipPlan = membershipPlan
        self.membershipCard = membershipCard
        self.router = router
    }

    var shouldShowAddCardButton: Bool {
        guard membershipPlan.isPLR else { return true }
        return membershipPlan.canAddCard
    }
    
    func getMembershipPlan() -> CD_MembershipPlan {
        return membershipPlan
    }
    
    func toAuthAndAddScreen() {
        guard let existingCard = membershipCard else {
            router.toAuthAndAddViewController(membershipPlan: membershipPlan, formPurpose: .add)
            return
        }
        router.toAuthAndAddViewController(membershipPlan: membershipPlan, formPurpose: .addFailed, existingMembershipCard: existingCard)
    }
    
    func didSelectAddNewCard() {
        // PLR
        if membershipPlan.isPLR == true && !Current.wallet.hasValidPaymentCards {
            toPaymentCardNeededScreen()
            return
        }

        let fields = membershipPlan.featureSet?.formattedLinkingSupport
        guard (fields?.contains(where: { $0.value == LinkingSupportType.enrol.rawValue }) ?? false) else {
            toNativeJoinUnavailable()
            return
        }
        
        guard let existingCard = membershipCard else {
            router.toAuthAndAddViewController(membershipPlan: membershipPlan, formPurpose: .signUp)
            return
        }
        router.toAuthAndAddViewController(membershipPlan: membershipPlan, formPurpose: .signUpFailed, existingMembershipCard: existingCard)
    }
    
    func toNativeJoinUnavailable() {
        let descriptionText = String(format: "native_join_unavailable_description".localized, membershipPlan.account?.companyName ?? "")
        let screenText = "native_join_unavailable_title".localized + "\n" + descriptionText
        
        let attributedText = NSMutableAttributedString(string: screenText)
        attributedText.addAttribute(NSAttributedString.Key.font, value: UIFont.headline, range: NSRange(location: 0, length: ("native_join_unavailable_title".localized).count)
        )
        attributedText.addAttribute(NSAttributedString.Key.font, value: UIFont.bodyTextLarge, range: NSRange(location: ("native_join_unavailable_title".localized).count, length: descriptionText.count)
        )
        
        var configurationModel: ReusableModalConfiguration
        
        guard let planURL = membershipPlan.account?.planURL else {
            configurationModel = ReusableModalConfiguration(title: "", text: attributedText, showCloseButton: true)
            router.toReusableModalTemplateViewController(configurationModel: configurationModel)
            return
        }
        
        configurationModel = ReusableModalConfiguration(title: "", text: attributedText, primaryButtonTitle: "to_merchant_site_button".localized, mainButtonCompletion: {
            if let url = URL(string: planURL) {
                UIApplication.shared.open(url)
            }
        }, showCloseButton: true)
        
        router.toReusableModalTemplateViewController(configurationModel: configurationModel, floatingButtons: false)
    }
    
    func brandHeaderWasTapped() {
        let title: String = membershipPlan.account?.planName ?? ""
        let description: String = membershipPlan.account?.planDescription ?? ""
        
        let attributedString = NSMutableAttributedString()
        let attributedTitle = NSAttributedString(string: title + "\n", attributes: [NSAttributedString.Key.font : UIFont.headline])
        let attributedBody = NSAttributedString(string: description, attributes: [NSAttributedString.Key.font : UIFont.bodyTextLarge])
        attributedString.append(attributedTitle)
        attributedString.append(attributedBody)
        
        let configuration = ReusableModalConfiguration(title: title, text: attributedString, showCloseButton: true)
        router.toReusableModalTemplateViewController(configurationModel: configuration)
    }
    
    func displaySimplePopup(title: String?, message: String?) {
        router.displaySimplePopup(title: title, message: message)
    }
    
    @objc func popViewController() {
        router.popViewController()
    }
    
    @objc func dismissViewController() {
        router.dismissViewController()
    }
    
    func popToRootViewController() {
        router.popToRootViewController()
    }

    private func toPaymentCardNeededScreen() {
        router.toPaymentCardNeededScreen()
    }
}
