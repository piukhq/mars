//
//  FormViewModel.swift
//  binkapp
//
//  Created by Sean Williams on 08/09/2021.
//  Copyright © 2021 Bink. All rights reserved.

import CardScan
import SwiftUI

final class FormViewModel: ObservableObject {
    @Published var datasource: FormDataSource
    @Published var date: Date?
    @Published var pickerData = (value: "", fieldCount: 0)
    @Published var addPaymentCardViewModel: AddPaymentCardViewModel?
    @Published var paymentCard: PaymentCardCreateModel?
    @Published var keyboardHeight: CGFloat = 0
    @Published var formInputType: FormInputType = .none {
        didSet {
            setKeyboardHeight()
        }
    }

    var titleText: String?
    var descriptionText: String?
    let membershipPlan: CD_MembershipPlan?
    private let strings = PaymentCardScannerStrings()
    var previousTextfieldValue = ""
    
    init(datasource: FormDataSource, title: String?, description: String?, membershipPlan: CD_MembershipPlan? = nil, addPaymentCardViewModel: AddPaymentCardViewModel? = nil) {
        self.datasource = datasource
        self.titleText = title
        self.descriptionText = description
        self.membershipPlan = membershipPlan
        self.addPaymentCardViewModel = addPaymentCardViewModel
        self.paymentCard = addPaymentCardViewModel?.paymentCard
    }

    var shouldShowTextfieldToolbar: Bool {
        if case .none = formInputType {
            return false
        }
        return true
    }
    
    func setKeyboardHeight() {
        switch formInputType {
        case .date:
            if #available(iOS 14.0, *) {
                keyboardHeight = FormViewConstants.graphicalDatePickerHeight - FormViewConstants.vStackInsets.bottom
            } else {
                keyboardHeight = FormViewConstants.datePickerHeight
            }
        case .choice:
            keyboardHeight = FormViewConstants.multipleChoicePickerHeight
        case .none:
            keyboardHeight = 0
        default:
            break
        }
    }
    
    func toLoyaltyScanner() {
        let viewController = ViewControllerFactory.makeLoyaltyScannerViewController(forPlan: membershipPlan, delegate: self)
        PermissionsUtility.launchLoyaltyScanner(viewController) {
            let navigationRequest = ModalNavigationRequest(viewController: viewController)
            Current.navigate.to(navigationRequest)
        }
    }
    
    func toPaymentCardScanner() {
        guard let viewController = ViewControllerFactory.makePaymentCardScannerViewController(strings: strings, delegate: self) else { return }
        PermissionsUtility.launchPaymentScanner(viewController) {
            let navigationRequest = ModalNavigationRequest(viewController: viewController)
            Current.navigate.to(navigationRequest)
        }
    }
    
    func toMagicLinkModal() {
        let viewController = ViewControllerFactory.makeWebViewController(urlString: "https://help.bink.com/hc/en-gb/articles/4404303824786")
        let navigationRequest = ModalNavigationRequest(viewController: viewController)
        Current.navigate.to(navigationRequest)
    }
    
    func configurePaymentCard(field: FormField, value: String) {
        if field.fieldType == .paymentCardNumber {
            let type = PaymentCardType.type(from: value)
            addPaymentCardViewModel?.setPaymentCardType(type)
            addPaymentCardViewModel?.setPaymentCardFullPan(value)
        }
        
        if field.fieldType == .text { addPaymentCardViewModel?.setPaymentCardName(value) }
        paymentCard = addPaymentCardViewModel?.paymentCard
    }
    
    func formatPickerData(pickerOne: String, pickerTwo: String ) {
        switch formInputType {
        case .expiry:
            if pickerTwo.isEmpty {
                pickerData = (pickerOne, 1)
            } else if pickerOne.isEmpty {
                pickerData = (pickerTwo, 1)
            } else {
                pickerData = (pickerOne + "/" + pickerTwo, 2)
            }
        default:
            pickerData = (pickerOne, 1)
        }
        datasource.checkFormValidity()
    }
}

extension FormViewModel: BarcodeScannerViewControllerDelegate {
    func barcodeScannerViewController(_ viewController: BarcodeScannerViewController, didScanBarcode barcode: String, forMembershipPlan membershipPlan: CD_MembershipPlan, completion: (() -> Void)?) {
        viewController.dismiss(animated: true) {
            var prefilledValues = self.datasource.fields.filter { $0.fieldCommonName != .barcode && $0.fieldCommonName != .cardNumber }.map {
                FormDataSource.PrefilledValue(commonName: $0.fieldCommonName, value: $0.value)
            }
            prefilledValues.append(FormDataSource.PrefilledValue(commonName: .barcode, value: barcode))
            self.datasource = FormDataSource(authAdd: membershipPlan, formPurpose: .addFromScanner, prefilledValues: prefilledValues)
        }
    }
    
    func barcodeScannerViewControllerShouldEnterManually(_ viewController: BarcodeScannerViewController, completion: (() -> Void)?) {
        viewController.dismiss(animated: true)
    }
}

extension FormViewModel: ScanDelegate {
    func userDidCancel(_ scanViewController: ScanViewController) {
        Current.navigate.close()
    }
    
    func userDidScanCard(_ scanViewController: ScanViewController, creditCard: CreditCard) {
        guard let viewModel = addPaymentCardViewModel else { return }
        if #available(iOS 14.0, *) {
            BinkLogger.infoPrivateHash(event: AppLoggerEvent.paymentCardScanned, value: creditCard.number)
        }
        BinkAnalytics.track(GenericAnalyticsEvent.paymentScan(success: true))
        let month = creditCard.expiryMonthInteger() ?? viewModel.paymentCard.month
        let year = creditCard.expiryYearInteger() ?? viewModel.paymentCard.year
        Current.navigate.close(animated: true) {
            let paymentCardCreateModel = PaymentCardCreateModel(fullPan: creditCard.number, nameOnCard: viewModel.paymentCard.nameOnCard, month: month, year: year)
//            self.card.configureWithAddViewModel(paymentCardCreateModel)
            viewModel.paymentCard = paymentCardCreateModel
            self.datasource = FormDataSource(paymentCardCreateModel)
//            self.formValidityUpdated(fullFormIsValid: self.dataSource.fullFormIsValid)
        }
    }
    
    func userDidSkip(_ scanViewController: ScanViewController) {
        Current.navigate.close()
    }
}

enum BarcodeScannerType {
    case loyalty
    case payment
}

enum FormInputType {
    case date
    case choice(data: [FormPickerData])
    case expiry(months: [FormPickerData], years: [FormPickerData])
    case keyboard(title: String)
    case secureEntry
    case none
}
