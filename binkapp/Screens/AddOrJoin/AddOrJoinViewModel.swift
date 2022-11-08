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
    
    var shouldShowNewCardButton: Bool {
        let planSupportsEnrol = membershipPlan.featureSet?.hasLinkingSupportForType(.enrol) ?? false
        return planSupportsEnrol && membershipPlan.account?.hasEnrolFields ?? false
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
        let descriptionText = L10n.nativeJoinUnavailableDescription(membershipPlan.account?.companyName ?? "")
        let screenText = L10n.nativeJoinUnavailableTitle + "\n" + descriptionText
        
        let attributedText = NSMutableAttributedString(string: screenText)
        attributedText.addAttribute(NSAttributedString.Key.font, value: UIFont.headline, range: NSRange(location: 0, length: (L10n.nativeJoinUnavailableTitle).count)
        )
        attributedText.addAttribute(NSAttributedString.Key.font, value: UIFont.bodyTextLarge, range: NSRange(location: (L10n.nativeJoinUnavailableTitle).count, length: descriptionText.count)
        )
        
        var configurationModel: ReusableModalConfiguration
        
        guard let planURL = membershipPlan.account?.planURL else {
            configurationModel = ReusableModalConfiguration(title: "", text: attributedText)
            let viewController = ViewControllerFactory.makeReusableTemplateViewController(configuration: configurationModel)
            let navigationRequest = ModalNavigationRequest(viewController: viewController)
            Current.navigate.to(navigationRequest)
            return
        }
        
        configurationModel = ReusableModalConfiguration(title: "", text: attributedText, primaryButtonTitle: L10n.toMerchantSiteButton, primaryButtonAction: {
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
        let configuration = ReusableModalConfiguration(title: "", text: ReusableModalConfiguration.makeAttributedString(title: L10n.plrPaymentCardNeededTitle, description: L10n.plrPaymentCardNeededBody), primaryButtonTitle: L10n.pllScreenAddTitle, primaryButtonAction: { [weak self] in
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
//        let viewController = ViewControllerFactory.makeScannerViewController(type: .payment, delegate: Current.navigate.scannerDelegate)

        // TODO: Delete once payment scanner is switched
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
