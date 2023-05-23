//
//  ViewControllerFactory.swift
//  binkapp
//
//  Created by Nick Farrant on 16/09/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import UIKit
import SwiftUI

enum ViewControllerFactory {
    // MARK: - Adding Cards
    
    static func makeScannerViewController(type: ScanType, forPlan plan: CD_MembershipPlan? = nil, hideNavigationBar: Bool = true, delegate: BinkScannerViewControllerDelegate?) -> BinkScannerViewController {
        let viewModel = BarcodeScannerViewModel(plan: plan, type: type)
        return BinkScannerViewController(viewModel: viewModel, hideNavigationBar: hideNavigationBar, delegate: delegate)
    }
    
    static func makeBrowseBrandsViewController(section: Int? = nil) -> BrowseBrandsViewController {
        return BrowseBrandsViewController(viewModel: BrowseBrandsViewModel(), section: section)
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
    
    static func makePaymentTermsAndConditionsViewController(acceptAction: BinkButtonAction? = nil) -> UIViewController {
        let viewController = UIHostingController(rootView: TermsAndConditionsView(viewModel: TermsAndConditionsViewModel(acceptAction: acceptAction)))
        viewController.view.backgroundColor = Current.themeManager.color(for: .viewBackground)
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
    
    static func makeLoyaltyCardDetailViewController(membershipCard: CD_MembershipCard, animateContent: Bool = true) -> LoyaltyCardFullDetailsViewController {
        let factory = WalletCardDetailInformationRowFactory()
        let viewModel = LoyaltyCardFullDetailsViewModel(membershipCard: membershipCard, informationRowFactory: factory, animated: animateContent)
        let viewController = LoyaltyCardFullDetailsViewController(viewModel: viewModel)
        factory.delegate = viewController
        return viewController
    }
    
    static func makePollViewController() -> UIViewController {
        let viewModel = PollSwiftUIViewModel()
        return UIHostingController(rootView: PollSwiftUIView(viewModel: viewModel))
    }
    
    static func makeBarcodeViewController(membershipCard: CD_MembershipCard) -> UIViewController {
        let viewModel = BarcodeViewModel(membershipCard: membershipCard)
        return UIHostingController(rootView: BarcodeScreenSwiftUIView(viewModel: viewModel))
    }
    
    static func makeGeoLocationsViewController(companyName: String) -> GeoLocationsViewController {
        let viewModel = GeoLocationViewModel(companyName: companyName)
        return GeoLocationsViewController(viewModel: viewModel)
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
        
        return makeReusableTemplateViewController(configuration: configuration, floatingButtons: true)
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
    
    static func makeSettingsViewController(rowsWithActionRequired: [SettingsRow.RowType]?) -> UIViewController {
        let viewModel = SettingsViewModel(rowsWithActionRequired: rowsWithActionRequired)
        return UIHostingController(rootView: SettingsView(viewModel: viewModel))
    }
    
    static func makeWhatsNewViewController(viewModel: WhatsNewViewModel) -> UIViewController {
        return UIHostingController(rootView: WhatsNewSwiftUIView(viewModel: viewModel))
    }

    // MARK: - Onboarding

    static func makeOnboardingViewController() -> PortraitNavigationController {
        return PortraitNavigationController(rootViewController: OnboardingViewController())
    }

    static func makeSocialTermsAndConditionsViewController(requestType: LoginRequestType) -> TermsAndConditionsViewController {
        return TermsAndConditionsViewController(requestType: requestType)
    }
    
    static func makeLoginSuccessViewController() -> LoginSuccessViewController {
        return LoginSuccessViewController()
    }

    static func makeLoginViewController() -> LoginViewController {
        return LoginViewController()
    }

    static func makeForgottenPasswordViewController() -> ForgotPasswordViewController {
        let viewModel = ForgotPasswordViewModel(repository: ForgotPasswordRepository())
        return ForgotPasswordViewController(viewModel: viewModel)
    }
    
    static func makeCheckYourInboxViewController(configuration: ReusableModalConfiguration) -> CheckYourInboxViewController {
        let viewModel = ReusableModalViewModel(configurationModel: configuration)
        return CheckYourInboxViewController(viewModel: viewModel)
    }
    
    // MARK: - Local Points Collection
    
    static func makeLocalPointsCollectionBalanceRefreshViewController(membershipCard: CD_MembershipCard, lastCheckedDate: Date?) -> ReusableTemplateViewController {
        let buttonAction: BinkButtonAction = {
            Current.navigate.close {
                Current.pointsScrapingManager.performBalanceRefresh(for: membershipCard)
            }
        }
        let planName = membershipCard.membershipPlan?.account?.planName ?? ""
        let lastCheckedString = L10n.lpcPointsModuleBalanceExplainerBodyTimeAgo(lastCheckedDate?.timeAgoString() ?? "")
        let refreshIntervalString = Current.pointsScrapingManager.isDebugMode ? WalletRefreshManager.RefreshInterval.twoMinutes.readableValue : WalletRefreshManager.RefreshInterval.twelveHours.readableValue
        
        var bodyText = ""
        var showRefreshButton = false
        switch WalletRefreshManager.cardCanBeForceRefreshed(membershipCard) {
        case true:
            if Current.pointsScrapingManager.isCurrentlyScraping(forMembershipCard: membershipCard) {
                bodyText = L10n.lpcPointsModuleBalanceExplainerBodyRefreshRequested(planName, lastCheckedString, refreshIntervalString)
            } else {
                bodyText = L10n.lpcPointsModuleBalanceExplainerBodyRefreshable(planName, lastCheckedString, refreshIntervalString)
                showRefreshButton = true
            }
        case false:
            bodyText = L10n.lpcPointsModuleBalanceExplainerBody(planName, lastCheckedString, refreshIntervalString)
        }
        let attributedString = ReusableModalConfiguration.makeAttributedString(title: L10n.lpcPointsModuleBalanceExplainerTitle, description: bodyText)
        let baseBodyText = NSString(string: attributedString.string)
        let lastCheckedRange = baseBodyText.range(of: lastCheckedString)
        attributedString.addAttribute(NSAttributedString.Key.font, value: UIFont.buttonText, range: lastCheckedRange)
        
        let config = ReusableModalConfiguration(title: "", text: attributedString, primaryButtonTitle: showRefreshButton ?  L10n.lpcPointsModuleBalanceExplainerButtonTitle : nil, primaryButtonAction: showRefreshButton ? buttonAction : nil, secondaryButtonTitle: nil, secondaryButtonAction: nil, membershipPlan: membershipCard.membershipPlan)
        
        let viewModel = ReusableModalViewModel(configurationModel: config)
        return ReusableTemplateViewController(viewModel: viewModel)
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
    
    static func makeOkCancelAlertViewController(title: String?, message: String?, okActionTitle: String? = nil, cancelButton: Bool? = nil, completion: EmptyCompletionBlock? = nil) -> BinkAlertController {
        let alert = BinkAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: okActionTitle ?? L10n.ok, style: .default, handler: { _ in
            completion?()
        }))
        
        alert.addAction(UIAlertAction(title: L10n.cancel, style: .cancel))
        return alert
    }
    
    static func makeTwoButtonAlertViewController(title: String?, message: String?, primaryButtonTitle: String, secondaryButtonTitle: String, primaryButtonCompletion: @escaping EmptyCompletionBlock, secondaryButtonCompletion: @escaping EmptyCompletionBlock) -> BinkAlertController {
        let alert = BinkAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: primaryButtonTitle, style: .default, handler: { _ in
            primaryButtonCompletion()
        }))
        
        alert.addAction(UIAlertAction(title: secondaryButtonTitle, style: .default, handler: { _ in
            secondaryButtonCompletion()
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
    
    static func makeAlertViewControllerWithTextfield(title: String?, message: String?, cancelButton: Bool?, keyboardType: UIKeyboardType, okActionHandler: @escaping (String) -> Void, cancelActionHandler: EmptyCompletionBlock? = nil ) -> BinkAlertController {
        let alert = BinkAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addTextField { textfield in
            textfield.keyboardType = keyboardType
            
            if keyboardType == .numberPad {
                textfield.textContentType = .oneTimeCode
            }
        }
        alert.addAction(UIAlertAction(title: L10n.ok, style: .default, handler: { _ in
            okActionHandler(alert.textFields?[0].text ?? "")
        }))
        
        alert.addAction(UIAlertAction(title: L10n.cancel, style: .cancel, handler: { _ in
            cancelActionHandler?()
        }))
        return alert
    }
    
    static func makeMapNavigationSelectionAlertViewController(appleMapsActionHandler: @escaping () -> Void, googleMapsActionHandler: @escaping () -> Void, cancelActionHandler: @escaping () -> Void ) -> BinkAlertController {
        let alert = BinkAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "Apple Maps", style: .default, handler: { _ in
            appleMapsActionHandler()
        }))
        
        alert.addAction(UIAlertAction(title: "Google Maps", style: .default, handler: { _ in
            googleMapsActionHandler()
        }))
        
        alert.addAction(UIAlertAction(title: L10n.cancel, style: .cancel, handler: { _ in
            cancelActionHandler()
        }))
        return alert
    }
    
    static func makePollManagementAlertViewController(remindLaterHandler: @escaping () -> Void, dontShowAgainHandler: @escaping () -> Void ) -> BinkAlertController {
        let alert = BinkAlertController(title: L10n.dismissAlertTitle, message: nil, preferredStyle: .actionSheet)

        let remindAction = UIAlertAction(title: L10n.remindMeLater, style: .default, handler: { _ in
            remindLaterHandler()
        })
        alert.addAction(remindAction)
        
        alert.addAction(UIAlertAction(title: L10n.dismissPoll, style: .destructive, handler: { _ in
            dontShowAgainHandler()
        }))
        
        let cancelAction = UIAlertAction(title: L10n.cancel, style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        return alert
    }

    static func makeDebugViewController() -> UIViewController {
        return UIHostingController(rootView: DebugMenuView())
    }

    static func makeJailbrokenViewController() -> JailbrokenViewController {
        return JailbrokenViewController()
    }
    
    static func makeEmailClientsAlertController(_ emailClients: [EmailClient]) -> BinkAlertController {
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
