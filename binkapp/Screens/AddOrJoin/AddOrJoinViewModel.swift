//
//  AddOrJoinViewModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit
import CardScan

class AddOrJoinViewModel {
    private let membershipPlan: CD_MembershipPlan
    private let membershipCard: CD_MembershipCard?
        
    init(membershipPlan: CD_MembershipPlan, membershipCard: CD_MembershipCard? = nil) {
        self.membershipPlan = membershipPlan
        self.membershipCard = membershipCard
    }

    var shouldShowAddCardButton: Bool {
        guard membershipPlan.isPLR else { return true }
        return membershipPlan.canAddCard
    }
    
    func getMembershipPlan() -> CD_MembershipPlan {
        return membershipPlan
    }
    
    func toAuthAndAddScreen() {
        // PLR
        if membershipPlan.isPLR == true && !Current.wallet.hasValidPaymentCards {
            toPaymentCardNeededScreen()
            return
        }
        
        guard let existingCard = membershipCard else {
            let viewController = ViewControllerFactory.makeAuthAndAddViewController(membershipPlan: membershipPlan, formPurpose: .add)
            let navigationRequest = PushNavigationRequest(viewController: viewController)
            Current.navigate.to(navigationRequest)
            return
        }
        let viewController = ViewControllerFactory.makeAuthAndAddViewController(membershipPlan: membershipPlan, formPurpose: .addFailed, existingMembershipCard: existingCard)
        let navigationRequest = PushNavigationRequest(viewController: viewController)
        Current.navigate.to(navigationRequest)
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
            let viewController = ViewControllerFactory.makeAuthAndAddViewController(membershipPlan: membershipPlan, formPurpose: .signUp)
            let navigationRequest = PushNavigationRequest(viewController: viewController)
            Current.navigate.to(navigationRequest)
            return
        }
        let viewController = ViewControllerFactory.makeAuthAndAddViewController(membershipPlan: membershipPlan, formPurpose: .signUpFailed, existingMembershipCard: existingCard)
        let navigationRequest = PushNavigationRequest(viewController: viewController)
        Current.navigate.to(navigationRequest)
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
            configurationModel = ReusableModalConfiguration(title: "", text: attributedText)
            let viewController = ViewControllerFactory.makeReusableTemplateViewController(configuration: configurationModel)
            let navigationRequest = ModalNavigationRequest(viewController: viewController)
            Current.navigate.to(navigationRequest)
            return
        }
        
        configurationModel = ReusableModalConfiguration(title: "", text: attributedText, primaryButtonTitle: "to_merchant_site_button".localized, mainButtonCompletion: {
            if let url = URL(string: planURL) {
                let viewController = ViewControllerFactory.makeWebViewController(urlString: url.absoluteString)
                let navigationRequest = ModalNavigationRequest(viewController: viewController)
                Current.navigate.to(navigationRequest)
            }
        })

        let viewController = ViewControllerFactory.makeReusableTemplateViewController(configuration: configurationModel)
        let navigationRequest = ModalNavigationRequest(viewController: viewController)
        Current.navigate.to(navigationRequest)
    }
    
    func brandHeaderWasTapped() {
        let viewController = ViewControllerFactory.makeAboutMembershipPlanViewController(membershipPlan: membershipPlan)
        let navigationRequest = ModalNavigationRequest(viewController: viewController)
        Current.navigate.to(navigationRequest)
    }

    private func toPaymentCardNeededScreen() {
        let configuration = ReusableModalConfiguration(title: "", text: ReusableModalConfiguration.makeAttributedString(title: "plr_payment_card_needed_title".localized, description: "plr_payment_card_needed_body".localized), primaryButtonTitle: "pll_screen_add_title".localized, mainButtonCompletion: { [weak self] in
            guard let self = self else { return }
            Current.navigate.close {
                self.toPaymentCardScanner()
            }
        })
        let viewController = ViewControllerFactory.makeReusableTemplateViewController(configuration: configuration, floatingButtons: false)
        let navigationRequest = PushNavigationRequest(viewController: viewController)
        Current.navigate.to(navigationRequest)
    }
    
    private func toPaymentCardScanner() {
        guard let viewController = ViewControllerFactory.makePaymentCardScannerViewController(strings: Current.paymentCardScannerStrings, delegate: Current.navigate.paymentCardScannerDelegate) else { return }

        PermissionsUtility.launchPaymentScanner(viewController, grantedAction: {
            let navigationRequest = ModalNavigationRequest(viewController: viewController)
            Current.navigate.to(navigationRequest)
        }, enterManuallyAction: {
            let viewController = ViewControllerFactory.makeAddPaymentCardViewController(journey: .wallet)
            let navigationRequest = ModalNavigationRequest(viewController: viewController)
            Current.navigate.to(navigationRequest)
        })
    }
}
