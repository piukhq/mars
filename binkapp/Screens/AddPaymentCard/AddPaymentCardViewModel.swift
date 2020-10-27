//
//  AddPaymentCardViewModel.swift
//  binkapp
//
//  Created by Nick Farrant on 27/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

enum AddPaymentCardJourney {
    case wallet
    case pll
}

class AddPaymentCardViewModel {
    private let repository = PaymentWalletRepository()
    private let journey: AddPaymentCardJourney
    let paymentCard: PaymentCardCreateModel // Exposed to allow realtime updating

    var shouldDisplayTermsAndConditions: Bool {
        return true
    }
    
    init(paymentCard: PaymentCardCreateModel? = nil, journey: AddPaymentCardJourney) {
        self.paymentCard = paymentCard ?? PaymentCardCreateModel(fullPan: nil, nameOnCard: nil, month: nil, year: nil)
        self.journey = journey
    }

    var formDataSource: FormDataSource {
        return FormDataSource(paymentCard)
    }

    var paymentCardType: PaymentCardType? {
        return paymentCard.cardType
    }
    
    //TODO: Check if we actually need these
    let strings = PaymentCardScannerStrings()

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

    func toPaymentTermsAndConditions(delegate: ReusableTemplateViewControllerDelegate?) {
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
        
        let configurationModel = ReusableModalConfiguration(title: "terms_and_conditions_title".localized, text: attributedText)
        let viewController = ViewControllerFactory.makePaymentTermsAndConditionsViewController(configurationModel: configurationModel, delegate: delegate)
        let navigationRequest = ModalNavigationRequest(viewController: viewController, dragToDismiss: false)
        Current.navigate.to(navigationRequest)
    }
    
    func toPrivacyAndSecurity() {
        let title: String = "security_and_privacy_title".localized
        let description: String = "security_and_privacy_description".localized
        let configuration = ReusableModalConfiguration(title: title, text: ReusableModalConfiguration.makeAttributedString(title: title, description: description))
        let viewController = ViewControllerFactory.makeSecurityAndPrivacyViewController(configuration: configuration)
        let navigationRequest = ModalNavigationRequest(viewController: viewController)
        Current.navigate.to(navigationRequest)
    }

    func addPaymentCard(onError: @escaping () -> Void) {
        repository.addPaymentCard(paymentCard, onSuccess: { [weak self] paymentCard in
            guard let self = self else { return }
            guard let paymentCard = paymentCard else { return }
            Current.wallet.refreshLocal()
            
            switch self.journey {
            case .wallet:
                let pcdViewController = ViewControllerFactory.makePaymentCardDetailViewController(paymentCard: paymentCard)
                let pcdNavigationRequest = PushNavigationRequest(viewController: pcdViewController)
                let tabNavigationRequest = TabBarNavigationRequest(tab: .payment, popToRoot: true, backgroundPushNavigationRequest: pcdNavigationRequest) {
                    Current.navigate.close()
                }
                Current.navigate.to(tabNavigationRequest)
            case .pll:
                Current.navigate.close()
            }
        }) { error in
            onError()
            self.displayError()
        }
    }

    func displayError() {
        let alert = ViewControllerFactory.makeOkAlertViewController(title: "add_payment_error_title".localized, message: "add_payment_error_message".localized)
        Current.navigate.to(AlertNavigationRequest(alertController: alert))
    }
    
    func toPaymentCardScanner() {
        guard let viewController = ViewControllerFactory.makePaymentCardScannerViewController(strings: strings, allowSkip: false, delegate: Current.navigate.paymentCardScannerDelegate) else { return }
        
        let enterManuallyAlert = UIAlertController.cardScannerEnterManuallyAlertController {
            Current.navigate.close()
        }
        
        if PermissionsUtility.videoCaptureIsAuthorized {
            let navigationRequest = ModalNavigationRequest(viewController: viewController)
            Current.navigate.to(navigationRequest)
        } else if PermissionsUtility.videoCaptureIsDenied {
            if let alert = enterManuallyAlert {
                let navigationRequest = AlertNavigationRequest(alertController: alert)
                Current.navigate.to(navigationRequest)
            }
        } else {
            PermissionsUtility.requestVideoCaptureAuthorization { granted in
                if granted {
                    let navigationRequest = ModalNavigationRequest(viewController: viewController)
                    Current.navigate.to(navigationRequest)
                } else {
                    if let alert = enterManuallyAlert {
                        let navigationRequest = AlertNavigationRequest(alertController: alert)
                        Current.navigate.to(navigationRequest)
                    }
                }
            }
        }
    }
    
//    func toAddPaymentCardScreen(model: PaymentCardCreateModel? = nil) {
//        Current.navigate.close()
////        Current.navigate.close {
////            let viewController = ViewControllerFactory.makeAddPaymentCardViewController(model: model, journey: .wallet)
////            let navigationRequest = ModalNavigationRequest(viewController: viewController)
////            Current.navigate.to(navigationRequest)
////        }
//    }
}
