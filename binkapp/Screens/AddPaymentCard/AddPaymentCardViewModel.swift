//
//  AddPaymentCardViewModel.swift
//  binkapp
//
//  Created by Nick Farrant on 27/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

struct AddPaymentCardViewModel {
    private let router: MainScreenRouter
    private let repository: PaymentWalletRepositoryProtocol
    let paymentCard: PaymentCardCreateModel // Exposed to allow realtime updating

    init(router: MainScreenRouter, repository: PaymentWalletRepositoryProtocol, paymentCard: PaymentCardCreateModel) {
        self.router = router
        self.repository = repository
        self.paymentCard = paymentCard
    }

    var formDataSource: FormDataSource {
        return FormDataSource(paymentCard)
    }

    var paymentCardType: PaymentCardType? {
        return paymentCard.cardType
    }

    func setPaymentCardType(_ cardType: PaymentCardType?) {
        paymentCard.cardType = cardType
    }

    func setPaymentCardFullPan(_ fullPan: String?) {
        paymentCard.fullPan = fullPan
    }

    func setPaymentCardName(_ nameOnCard: String?) {
        paymentCard.nameOnCard = nameOnCard
    }

    func setPaymentCardExpiry(month: Int?, year: Int?) {
        paymentCard.month = month
        paymentCard.year = year
    }

    func toPaymentTermsAndConditions(delegate: PaymentTermsAndConditionsViewControllerDelegate?) {
        let description = "terms_and_conditions_description".localized
        let titleAttributedString = NSMutableAttributedString(string: "terms_and_conditions_title".localized + "\n", attributes: [
            .font: UIFont.headline
        ])
        let descriptionAttributedString = NSMutableAttributedString(string: description, attributes: [
            .font: UIFont.bodyTextLarge
        ])
        let urlString = "privacy_policy".localized
        if let urlRange = description.range(of: urlString) {
            let nsRange = NSRange(urlRange, in: description)
            descriptionAttributedString.addAttribute(.link, value: "https://bink.com/privacy-policy/", range: nsRange)
        }

        let attributedText = NSMutableAttributedString()
        attributedText.append(titleAttributedString)
        attributedText.append(descriptionAttributedString)
        
        let configurationModel = ReusableModalConfiguration(title: "terms_and_conditions_title".localized, text: attributedText, tabBarBackButton: nil)
        
        router.toPaymentTermsAndConditionsViewController(configurationModel: configurationModel, delegate: delegate)
    }
    
    func toPrivacyAndSecurity() {
        router.toPrivacyAndSecurityViewController()
    }

    func addPaymentCard(completion: @escaping (Bool) -> Void) {
        repository.addPaymentCard(paymentCard, completion: completion)
    }

    func popToRootViewController() {
        router.popToRootViewController()
    }

    func displayError() {
        router.displaySimplePopup(title: "Oops", message: "Something went wrong.")
    }
}
