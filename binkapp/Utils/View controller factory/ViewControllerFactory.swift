//
//  ViewControllerFactory.swift
//  binkapp
//
//  Created by Nick Farrant on 16/09/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import UIKit
import CardScan

final class ViewControllerFactory {
    
    // MARK: - Adding Options
    
    static func makeAddingOptionsViewController() -> AddingOptionsViewController {
        return AddingOptionsViewController(viewModel: AddingOptionsViewModel())
    }
    
    static func makeLoyaltyScannerViewController(forPlan plan: CD_MembershipPlan? = nil, delegate: BarcodeScannerViewControllerDelegate?) -> BarcodeScannerViewController {
        let viewModel = BarcodeScannerViewModel(plan: plan)
        return BarcodeScannerViewController(viewModel: viewModel, delegate: delegate)
    }
    
    static func makeBrowseBrandsViewController() -> BrowseBrandsViewController {
        return BrowseBrandsViewController(viewModel: BrowseBrandsViewModel())
    }
    
    static func makePaymentCardScannerViewController(strings: ScanStringsDataSource, delegate: ScanDelegate?) -> ScanViewController? {
        guard let viewController = ScanViewController.createViewController(withDelegate: delegate) else { return nil }
        viewController.allowSkip = true
        viewController.cornerColor = .white
        viewController.torchButtonImage = UIImage(named: "payment_scanner_torch")
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
    
    static func makePaymentTermsAndConditionsViewController(configurationModel: ReusableModalConfiguration, delegate: ReusableTemplateViewControllerDelegate?) -> ReusableTemplateViewController {
        let viewModel = PaymentTermsAndConditionsViewModel(configurationModel: configurationModel)
        let viewController = ReusableTemplateViewController(viewModel: viewModel, delegate: delegate)
        viewController.delegate = delegate
        return viewController
    }
    
    // MARK: - Auth and add
    
    static func makePllViewController(membershipCard: CD_MembershipCard, journey: PllScreenJourney) -> PLLScreenViewController {
        let viewModel = PLLScreenViewModel(membershipCard: membershipCard, journey: journey)
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
    
    static func makeAboutMembershipPlanViewController(configuration: ReusableModalConfiguration, floatingButtons: Bool = true) -> ReusableTemplateViewController {
        return makeReusableTemplateViewController(configuration: configuration, floatingButtons: floatingButtons)
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
    
    // MARK: - Reusable
    
    static func makeReusableTemplateViewController(configuration: ReusableModalConfiguration, floatingButtons: Bool = true) -> ReusableTemplateViewController {
        let viewModel = ReusableModalViewModel(configurationModel: configuration)
        return ReusableTemplateViewController(viewModel: viewModel, floatingButtons: floatingButtons)
    }
    
    static func makeDeleteConfirmationAlertController(message: String, deleteAction: @escaping EmptyCompletionBlock, onCancel: EmptyCompletionBlock? = nil) -> UIAlertController {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "no".localized, style: .cancel, handler: { _ in
            onCancel?()
        }))
        alert.addAction(UIAlertAction(title: "yes".localized, style: .destructive, handler: { _ in
            deleteAction()
        }))
        return alert
    }
    
    static func makeNoConnectivityAlertController(completion: EmptyCompletionBlock? = nil) -> UIAlertController {
        let alert = UIAlertController(title: nil, message: "no_internet_connection_message".localized, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok".localized, style: .cancel, handler: { _ in
            if let completion = completion {
                completion()
            }
        }))
        return alert
    }
}
