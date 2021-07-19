//
//  ViewControllerFactory.swift
//  binkapp
//
//  Created by Nick Farrant on 16/09/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import UIKit
import CardScan
import SwiftUI

enum ViewControllerFactory {
    // MARK: - Adding Cards
    
    static func makeLoyaltyScannerViewController(forPlan plan: CD_MembershipPlan? = nil, hideNavigationBar: Bool = true, delegate: BarcodeScannerViewControllerDelegate?) -> BarcodeScannerViewController {
        let viewModel = BarcodeScannerViewModel(plan: plan)
        return BarcodeScannerViewController(viewModel: viewModel, hideNavigationBar: hideNavigationBar, delegate: delegate)
    }
    
    static func makeBrowseBrandsViewController(section: Int? = nil) -> BrowseBrandsViewController {
        return BrowseBrandsViewController(viewModel: BrowseBrandsViewModel(), section: section)
    }
    
    static func makePaymentCardScannerViewController(strings: ScanStringsDataSource, allowSkip: Bool = true, delegate: ScanDelegate?) -> ScanViewController? {
        guard let viewController = ScanViewController.createViewController(withDelegate: delegate) else { return nil }
        viewController.themeDelegate = Current.themeManager
        viewController.allowSkip = allowSkip
        viewController.cornerColor = .white
        viewController.torchButtonImage = Asset.paymentScannerTorch.image
        viewController.stringDataSource = strings
        return viewController
    }
    
    static func makeAddPaymentCardViewController(model: PaymentCardCreateModel? = nil, journey: AddPaymentCardJourney) -> AddPaymentCardViewController {
        let viewModel = AddPaymentCardViewModel(paymentCard: model, journey: journey)
        return AddPaymentCardViewController(viewModel: viewModel)
    }
    
    static func makeAddOrJoinViewController(membershipPlan: CD_MembershipPlan, membershipCard: CD_MembershipCard? = nil) -> AddOrJoinViewController {
        let viewModel = AddOrJoinViewModel(membershipPlan: membershipPlan, membershipCard: membershipCard)
        return AddOrJoinViewController(viewModel: viewModel)
    }
    
    static func makeAuthAndAddViewController(membershipPlan: CD_MembershipPlan, formPurpose: FormPurpose, existingMembershipCard: CD_MembershipCard? = nil, prefilledFormValues: [FormDataSource.PrefilledValue]? = nil) -> AuthAndAddViewController {
        let viewModel = AuthAndAddViewModel(membershipPlan: membershipPlan, formPurpose: formPurpose, existingMembershipCard: existingMembershipCard, prefilledFormValues: prefilledFormValues)
        return AuthAndAddViewController(viewModel: viewModel)
    }
    
    static func makePaymentTermsAndConditionsViewController(configurationModel: ReusableModalConfiguration) -> ReusableTemplateViewController {
        let viewModel = ReusableModalViewModel(configurationModel: configurationModel)
        let viewController = ReusableTemplateViewController(viewModel: viewModel)
        return viewController
    }
    
    // MARK: - Auth and add
    
    static func makePllViewController(membershipCard: CD_MembershipCard, journey: PllScreenJourney, delegate: LoyaltyCardFullDetailsModalDelegate? = nil) -> PLLScreenViewController {
        let viewModel = PLLScreenViewModel(membershipCard: membershipCard, journey: journey, delegate: delegate)
        return PLLScreenViewController(viewModel: viewModel, journey: journey)
    }
    
    static func makePatchGhostCardViewController(membershipPlan: CD_MembershipPlan, existingMembershipCard: CD_MembershipCard? = nil) -> AuthAndAddViewController {
        let viewModel = AuthAndAddViewModel(membershipPlan: membershipPlan, formPurpose: .patchGhostCard, existingMembershipCard: existingMembershipCard)
        return AuthAndAddViewController(viewModel: viewModel)
    }
    
    static func makeSignUpViewController(membershipPlan: CD_MembershipPlan, existingMembershipCard: CD_MembershipCard? = nil) -> AuthAndAddViewController {
        let viewModel = AuthAndAddViewModel(membershipPlan: membershipPlan, formPurpose: .signUp, existingMembershipCard: existingMembershipCard)
        return AuthAndAddViewController(viewModel: viewModel)
    }
    
    // MARK: - Loyalty Card Detail
    
    static func makeLoyaltyCardDetailViewController(membershipCard: CD_MembershipCard) -> LoyaltyCardFullDetailsViewController {
        let factory = WalletCardDetailInformationRowFactory()
        let viewModel = LoyaltyCardFullDetailsViewModel(membershipCard: membershipCard, informationRowFactory: factory)
        let viewController = LoyaltyCardFullDetailsViewController(viewModel: viewModel)
        factory.delegate = viewController
        return viewController
    }
    
    static func makeBarcodeViewController(membershipCard: CD_MembershipCard) -> BarcodeViewController {
        let viewModel = BarcodeViewModel(membershipCard: membershipCard)
        return BarcodeViewController(viewModel: viewModel)
    }
    
    static func makeVoucherDetailViewController(voucher: CD_Voucher, plan: CD_MembershipPlan) -> PLRRewardDetailViewController {
        let viewModel = PLRRewardDetailViewModel(voucher: voucher, plan: plan)
        return PLRRewardDetailViewController(viewModel: viewModel)
    }
    
    static func makeRewardsHistoryViewController(membershipCard: CD_MembershipCard) -> PLRRewardsHistoryViewController {
        let viewModel = PLRRewardsHistoryViewModel(membershipCard: membershipCard)
        return PLRRewardsHistoryViewController(viewModel: viewModel)
    }
    
    static func makeAboutMembershipPlanViewController(membershipPlan: CD_MembershipPlan) -> ReusableTemplateViewController {
        var titleString = ""
        if let planName = membershipPlan.account?.planName {
            titleString = L10n.aboutMembershipPlanTitle(planName)
        } else {
            titleString = L10n.aboutMembershipTitle
        }
        
        var descriptionString = ""
        if let planSummary = membershipPlan.account?.planSummary {
            descriptionString.append(planSummary)
            descriptionString.append("\n\n")
        }
        if let planDescription = membershipPlan.account?.planDescription {
            descriptionString.append(planDescription)
        }
        
        let attributedString = ReusableModalConfiguration.makeAttributedString(title: titleString, description: descriptionString)
        var configuration = ReusableModalConfiguration(text: attributedString)
        
        if let url = membershipPlan.account?.planURL {
            configuration = ReusableModalConfiguration(text: attributedString, primaryButtonTitle: L10n.goToSiteButton, primaryButtonAction: {
                /// Implemented navigation logic here instead of passing comletion block in via method property to reduce code repetition as it's called from multiple viewModels
                let viewController = makeWebViewController(urlString: url)
                let navigationRequest = ModalNavigationRequest(viewController: viewController)
                Current.navigate.to(navigationRequest)
            })
        }
        
        return makeReusableTemplateViewController(configuration: configuration, floatingButtons: true)
    }
    
    static func makeSecurityAndPrivacyViewController(configuration: ReusableModalConfiguration, floatingButtons: Bool = true) -> ReusableTemplateViewController {
        return makeReusableTemplateViewController(configuration: configuration, floatingButtons: floatingButtons)
    }
    
    static func makeTransactionsViewController(membershipCard: CD_MembershipCard) -> TransactionsViewController {
        let viewModel = TransactionsViewModel(membershipCard: membershipCard)
        return TransactionsViewController(viewModel: viewModel)
    }
    
    // MARK: - Payment Card Detail
    
    static func makePaymentCardDetailViewController(paymentCard: CD_PaymentCard) -> PaymentCardDetailViewController {
        let factory = WalletCardDetailInformationRowFactory()
        let viewModel = PaymentCardDetailViewModel(paymentCard: paymentCard, informationRowFactory: factory)
        let viewController = PaymentCardDetailViewController(viewModel: viewModel)
        factory.delegate = viewController
        return viewController
    }
    
    // MARK: - Wallets
    
    static func makeSettingsViewController(rowsWithActionRequired: [SettingsRow.RowType]?, delegate: SettingsViewControllerDelegate?) -> SettingsViewController {
        let viewModel = SettingsViewModel(rowsWithActionRequired: rowsWithActionRequired)
        return SettingsViewController(viewModel: viewModel, delegate: delegate)
    }

    // MARK: - Onboarding

    static func makeOnboardingViewController() -> PortraitNavigationController {
        return PortraitNavigationController(rootViewController: OnboardingViewController())
    }

    static func makeSocialTermsAndConditionsViewController(requestType: LoginRequestType) -> TermsAndConditionsViewController {
        return TermsAndConditionsViewController(requestType: requestType)
    }

//    static func makeRegisterViewController() -> RegisterViewController {
//        return RegisterViewController()
//    }

    static func makeLoginViewController() -> LoginViewController {
        return LoginViewController()
    }

    static func makeForgottenPasswordViewController() -> ForgotPasswordViewController {
        let viewModel = ForgotPasswordViewModel(repository: ForgotPasswordRepository())
        return ForgotPasswordViewController(viewModel: viewModel)
    }
    
    // MARK: - Reusable
    
    static func makeReusableTemplateViewController(configuration: ReusableModalConfiguration, floatingButtons: Bool = true) -> ReusableTemplateViewController {
        let viewModel = ReusableModalViewModel(configurationModel: configuration)
        return ReusableTemplateViewController(viewModel: viewModel)
    }
    
    static func makeDeleteConfirmationAlertController(message: String, deleteAction: @escaping EmptyCompletionBlock, onCancel: EmptyCompletionBlock? = nil) -> BinkAlertController {
        let alert = BinkAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: L10n.no, style: .cancel, handler: { _ in
            onCancel?()
        }))
        alert.addAction(UIAlertAction(title: L10n.yes, style: .destructive, handler: { _ in
            deleteAction()
        }))
        return alert
    }
    
    static func makeNoConnectivityAlertController(completion: EmptyCompletionBlock? = nil) -> BinkAlertController {
        let alert = BinkAlertController(title: nil, message: L10n.noInternetConnectionMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: L10n.ok, style: .cancel, handler: { _ in
            if let completion = completion {
                completion()
            }
        }))
        return alert
    }
    
    static func makeOkAlertViewController(title: String?, message: String?, completion: EmptyCompletionBlock? = nil) -> BinkAlertController {
        let alert = BinkAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: L10n.ok, style: .cancel, handler: { _ in
            completion?()
        }))
        return alert
    }
    
    static func makeRecommendedAppUpdateAlertController(skipVersionHandler: @escaping () -> Void) -> BinkAlertController {
        let alert = BinkAlertController(title: L10n.recommendedAppUpdateTitle, message: L10n.recommendedAppUpdateMessage, preferredStyle: .alert)
        
        let openAppStoreAction = UIAlertAction(title: L10n.recommendedAppUpdateAppStoreAction, style: .cancel) { _ in
            guard let url = URL(string: "https://apps.apple.com/gb/app/bink-loyalty-rewards-wallet/id1142153931"), UIApplication.shared.canOpenURL(url) else { return }
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            BinkAnalytics.track(RecommendedAppUpdateAnalyticsEvent.openAppStore)
        }
        
        let maybeLaterAction = UIAlertAction(title: L10n.recommendedAppUpdateMaybeLaterAction, style: .default) { _ in
            BinkAnalytics.track(RecommendedAppUpdateAnalyticsEvent.maybeLater)
        }
        
        let skipVersionAction = UIAlertAction(title: L10n.recommendedAppUpdateSkipVersionAction, style: .default) { _ in
            skipVersionHandler()
        }
        
        alert.addAction(openAppStoreAction)
        alert.addAction(maybeLaterAction)
        alert.addAction(skipVersionAction)
        
        return alert
    }
    
    static func makeWebViewController(urlString: String) -> WebViewController {
        return WebViewController(urlString: urlString)
    }

    static func makeDebugViewController() -> UIViewController {
        if #available(iOS 14.0, *) {
            return UIHostingController(rootView: DebugMenuView())
        } else {
            let debugMenuFactory = DebugMenuFactory()
            let debugMenuViewModel = DebugMenuViewModel(debugMenuFactory: debugMenuFactory)
            let debugMenuViewController = DebugMenuTableViewController(viewModel: debugMenuViewModel)
            debugMenuFactory.delegate = debugMenuViewController
            return debugMenuViewController
        }
    }

    static func makeJailbrokenViewController() -> JailbrokenViewController {
        return JailbrokenViewController()
    }
    
    static func makeEmailClientsAlertController(_ emailClients: [EmailClients]) -> BinkAlertController {
        let alert = BinkAlertController(title: L10n.openMailAlertTitle, message: nil, preferredStyle: .actionSheet)
        
        emailClients.forEach { emailClient in
            let action = UIAlertAction(title: emailClient.rawValue.capitalized, style: .default, handler: { _ in
                emailClient.open()
            })
            alert.addAction(action)
        }
        
        let cancelAction = UIAlertAction(title: L10n.cancel, style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        return alert
    }
}
