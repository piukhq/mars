//
//  AddPaymentCardViewModel.swift
//  binkapp
//
//  Created by Nick Farrant on 27/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import CardScan
import UIKit

enum AddPaymentCardJourney {
    case wallet
    case pll
}

final class AddPaymentCardViewModel: NSObject, ObservableObject {
    lazy var primaryButton: BinkButtonView = {
        return BinkButtonView(viewModel: buttonViewModel, title: L10n.addButtonTitle, buttonTapped: handlePrimaryButtonTap, type: .gradient)
    }()
    
    private let repository = PaymentWalletRepository()
    private let strings = PaymentCardScannerStrings()
    private let journey: AddPaymentCardJourney
    var buttonViewModel: ButtonViewModel

    var paymentCard: PaymentCardCreateModel // Exposed to allow realtime updating
    var datasource: FormDataSource
    
    init(paymentCard: PaymentCardCreateModel? = nil, journey: AddPaymentCardJourney) {
        self.journey = journey
        self.paymentCard = paymentCard ?? PaymentCardCreateModel(fullPan: nil, nameOnCard: nil, month: nil, year: nil)
        self.datasource = FormDataSource(self.paymentCard)
        self.buttonViewModel = ButtonViewModel(datasource: datasource)
        super.init()
        datasource.delegate = self
    }
    
    var shouldDisplayTermsAndConditions: Bool {
        return true
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
    
    private func handlePrimaryButtonTap() {
        if shouldDisplayTermsAndConditions {
            toPaymentTermsAndConditions(acceptAction: {
                Current.navigate.close {
                    self.addPaymentCard {
                        self.buttonViewModel.isLoading = false
                    }
                }
            }, declineAction: {
                Current.navigate.close()
            })
        } else {
            addPaymentCard {
                self.buttonViewModel.isLoading = false
            }
        }
    }

    private func toPaymentTermsAndConditions(acceptAction: @escaping BinkButtonAction, declineAction: @escaping BinkButtonAction) {
        let description = L10n.termsAndConditionsDescription
        let titleAttributedString = NSMutableAttributedString(string: L10n.termsAndConditionsTitle + "\n", attributes: [
            .font: UIFont.headline
        ])
        let descriptionAttributedString = NSMutableAttributedString(string: description, attributes: [
            .font: UIFont.bodyTextLarge
        ])
        let urlString = L10n.privacyPolicy
        if let urlRange = description.range(of: urlString) {
            let nsRange = NSRange(urlRange, in: description)
            descriptionAttributedString.addAttribute(.link, value: "https://bink.com/privacy-policy/", range: nsRange)
        }

        let attributedText = NSMutableAttributedString()
        attributedText.append(titleAttributedString)
        attributedText.append(descriptionAttributedString)
        
        let configurationModel = ReusableModalConfiguration(title: L10n.termsAndConditionsTitle, text: attributedText, primaryButtonTitle: L10n.iAccept, primaryButtonAction: acceptAction, secondaryButtonTitle: L10n.iDecline, secondaryButtonAction: declineAction)
        let viewController = ViewControllerFactory.makePaymentTermsAndConditionsViewController(configurationModel: configurationModel)
        let navigationRequest = ModalNavigationRequest(viewController: viewController, dragToDismiss: false, hideCloseButton: true)
        Current.navigate.to(navigationRequest)
    }

    private func addPaymentCard(onError: @escaping () -> Void) {
        repository.addPaymentCard(paymentCard, onSuccess: { [weak self] paymentCard in
            guard let self = self else { return }
            guard let paymentCard = paymentCard else { return }
            Current.wallet.refreshLocal()
            
            if #available(iOS 14.0, *) {
                BinkLogger.infoPrivateHash(event: PaymentCardLoggerEvent.paymentCardAdded, value: paymentCard.id)
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
        }) { _ in
            onError()
            self.displayError()
        }
    }

    func displayError() {
        let alert = ViewControllerFactory.makeOkAlertViewController(title: L10n.addPaymentErrorTitle, message: L10n.addPaymentErrorMessage)
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

extension AddPaymentCardViewModel: FormDataSourceDelegate, CheckboxViewDelegate {
    func formDataSource(_ dataSource: FormDataSource, textField: UITextField, shouldChangeTo newValue: String?, in range: NSRange, for field: FormField) -> Bool { return false }
    
    func formDataSource(_ dataSource: FormDataSource, manualValidate field: FormField) -> Bool {
        switch field.fieldType {
        case .expiry(months: _, years: _):
            // Create date using components from string e.g. 11/2019
            guard let dateStrings = field.value?.components(separatedBy: "/") else { return false }
            guard let monthString = dateStrings[safe: 0] else { return false }
            guard let yearString = dateStrings[safe: 1] else { return false }
            guard let month = Int(monthString) else { return false }
            guard let year = Int(yearString) else { return false }
            guard let expiryDate = Date.makeDate(year: year, month: month, day: 01, hr: 12, min: 00, sec: 00) else { return false }

            return expiryDate.monthHasNotExpired
        default:
            return false
        }
    }
    
    func checkboxView(_ checkboxView: CheckboxView, didCompleteWithColumn column: String, value: String, fieldType: FormField.ColumnKind) {}
    func checkboxView(_ checkboxView: CheckboxView, didTapOn URL: URL) {}
}
