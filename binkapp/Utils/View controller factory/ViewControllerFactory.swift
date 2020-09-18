//
//  ViewControllerFactory.swift
//  binkapp
//
//  Created by Nick Farrant on 16/09/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import UIKit

final class ViewControllerFactory {
    
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
    
    // MARK: - Payment Card Detail
    
    static func makePaymentCardDetailViewController(paymentCard: CD_PaymentCard) -> PaymentCardDetailViewController {
        let factory = WalletCardDetailInformationRowFactory()
        let viewModel = PaymentCardDetailViewModel(paymentCard: paymentCard, informationRowFactory: factory)
        let viewController = PaymentCardDetailViewController(viewModel: viewModel)
        factory.delegate = viewController
        return viewController
    }
    
    // MARK: - Reusable
    
    private static func makeReusableTemplateViewController(configuration: ReusableModalConfiguration, floatingButtons: Bool = true) -> ReusableTemplateViewController {
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
