//
//  AddPaymentCardViewModel.swift
//  binkapp
//
//  Created by Nick Farrant on 27/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import CardScan
import UIKit
import os

@available(iOS 14.0, *)
enum BinkLog {
    private static let subsystem = Bundle.main.bundleIdentifier ?? ""

    enum Category: String {
        case addPaymentCardViewModel
    }
    
    enum Event: String {
        case paymentCardAdded = "Payment card added"
    }
    
    // Debug - Not persisted: Not shown in exported logs
    
    static func debug(_ event: Event, value: String?, category: Category) {
        let logger = Logger(subsystem: subsystem, category: category.rawValue)
        logger.debug("\(event.rawValue, privacy: .public) \(value ?? "", privacy: .public)")
    }
    
    
    // Info - Only recent logs persisted, written to disk
    
    static func info(_ event: Event, value: String?, category: Category) {
        let logger = Logger(subsystem: subsystem, category: category.rawValue)
        logger.info("\(event.rawValue) \(value ?? "", privacy: .public)")
    }

    static func infoPrivate(_ event: Event, value: String, category: Category) {
        let logger = Logger(subsystem: subsystem, category: category.rawValue)
        logger.info("\(event.rawValue) \(value, privacy: .private)")
    }

    static func infoPrivateHash(_ event: Event, value: String, category: Category) {
        let logger = Logger(subsystem: subsystem, category: category.rawValue)
        logger.info("\(event.rawValue) \(value, privacy: .private(mask: .hash))")
    }


    // Log - For troubleshooting, written to memory and disk

    static func log(_ event: Event, value: String?, category: Category) {
        let logger = Logger(subsystem: subsystem, category: category.rawValue)
        logger.log("\(event.rawValue, privacy: .public) \(value ?? "", privacy: .public)")
    }

    static func logPrivate(_ event: Event, value: String, category: Category) {
        let logger = Logger(subsystem: subsystem, category: category.rawValue)
        logger.log("\(event.rawValue) \(value, privacy: .private)")
    }

    static func logPrivateHash(_ event: Event, value: String, category: Category) {
        let logger = Logger(subsystem: subsystem, category: category.rawValue)
        logger.log("\(event.rawValue) \(value, privacy: .private(mask: .hash))")
    }


    // Error - Persisted to memory and disk

    static func error(_ event: Event, value: String?, category: Category) {
        let logger = Logger(subsystem: subsystem, category: category.rawValue)
        logger.error("\(event.rawValue, privacy: .public) \(value ?? "", privacy: .public)")
    }
    
    static func errorPrivate(_ event: Event, value: String, category: Category) {
        let logger = Logger(subsystem: subsystem, category: category.rawValue)
        logger.error("\(event.rawValue, privacy: .public) \(value, privacy: .private)")
    }
}

enum AddPaymentCardJourney {
    case wallet
    case pll
}

class AddPaymentCardViewModel {
    private let repository = PaymentWalletRepository()
    private let journey: AddPaymentCardJourney
    private let strings = PaymentCardScannerStrings()
    var paymentCard: PaymentCardCreateModel // Exposed to allow realtime updating

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

    func toPaymentTermsAndConditions(acceptAction: @escaping BinkButtonAction, declineAction: @escaping BinkButtonAction) {
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
        
        let configurationModel = ReusableModalConfiguration(title: "terms_and_conditions_title".localized, text: attributedText, primaryButtonTitle: "i_accept".localized, primaryButtonAction: acceptAction, secondaryButtonTitle: "i_decline".localized, secondaryButtonAction: declineAction)
        let viewController = ViewControllerFactory.makePaymentTermsAndConditionsViewController(configurationModel: configurationModel)
        let navigationRequest = ModalNavigationRequest(viewController: viewController, dragToDismiss: false, hideCloseButton: true)
        Current.navigate.to(navigationRequest)
    }
    
    func toPrivacyAndSecurity() {
//        let title: String = "security_and_privacy_title".localized
//        let description: String = "security_and_privacy_description".localized
//        let configuration = ReusableModalConfiguration(title: title, text: ReusableModalConfiguration.makeAttributedString(title: title, description: description))
//        let viewController = ViewControllerFactory.makeSecurityAndPrivacyViewController(configuration: configuration)
//        let navigationRequest = ModalNavigationRequest(viewController: viewController)
//        Current.navigate.to(navigationRequest)

        let num = 5555555545499873
        
        if #available(iOS 14.0, *) {
            BinkLog.debug(.paymentCardAdded, value: String(num), category: .addPaymentCardViewModel)
            BinkLog.debug(.paymentCardAdded, value: nil, category: .addPaymentCardViewModel)
            BinkLog.info(.paymentCardAdded, value: String(num), category: .addPaymentCardViewModel)
            BinkLog.infoPrivate(.paymentCardAdded, value: String(num), category: .addPaymentCardViewModel)
            BinkLog.infoPrivateHash(.paymentCardAdded, value: String(num), category: .addPaymentCardViewModel)
            BinkLog.error(.paymentCardAdded, value: (String(num)), category: .addPaymentCardViewModel)
            BinkLog.errorPrivate(.paymentCardAdded, value: (String(num)), category: .addPaymentCardViewModel)
            BinkLog.log(.paymentCardAdded, value: String(num), category: .addPaymentCardViewModel)
            BinkLog.logPrivate(.paymentCardAdded, value: String(num), category: .addPaymentCardViewModel)
            BinkLog.logPrivateHash(.paymentCardAdded, value: String(num), category: .addPaymentCardViewModel)
        }
        
//        let uuid = "09390839083938"
//
//        if #available(iOS 14.0, *) {
//            let logger = Logger(subsystem: "com.bink.wallet", category: "AddPaymentCardViewModel")
//            logger.info("Payment card added \(uuid, privacy: .public)")
//            logger.info("Feed downloaded. Contents UUID is \(uuid, privacy: .private(mask: .hash))")
//            logger.log("SEAN \(uuid)")
//            logger.error("ERRRRROR: \(uuid, privacy: .private(mask: .hash))")
//            logger.error("Bello this is an error: \(uuid, privacy: .public)")
//        }
    }

    func addPaymentCard(onError: @escaping () -> Void) {
        repository.addPaymentCard(paymentCard, onSuccess: { [weak self] paymentCard in
            guard let self = self else { return }
            guard let paymentCard = paymentCard else { return }
            Current.wallet.refreshLocal()
            
            if #available(iOS 14.0, *) {
                BinkLog.infoPrivateHash(.paymentCardAdded, value: paymentCard.id, category: .addPaymentCardViewModel)
            }
            
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
        }) { [self] error in
            onError()
//            logger.error("Error adding payment card: \(error?.message ?? "", privacy: .public)")
            self.displayError()
        }
    }

    func displayError() {
        let alert = ViewControllerFactory.makeOkAlertViewController(title: "add_payment_error_title".localized, message: "add_payment_error_message".localized)
        Current.navigate.to(AlertNavigationRequest(alertController: alert))
    }
    
    func toPaymentCardScanner(delegate scanDelegate: ScanDelegate?) {
        guard let viewController = ViewControllerFactory.makePaymentCardScannerViewController(strings: strings, delegate: scanDelegate) else { return }
        PermissionsUtility.launchPaymentScanner(viewController) {
            let navigationRequest = ModalNavigationRequest(viewController: viewController)
            Current.navigate.to(navigationRequest)
        }
    }
}
