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
    @Published var textfieldDidExit = false // ?? Still being used?
    @Published var showtextFieldToolbar = false
    @Published var checkedState = false
    @Published var pickerType: PickerType = .none
    @Published var date = Date()
    @Published var pickerData = ""
    @Published var addPaymentCardViewModel: AddPaymentCardViewModel?
    @Published var paymentCard: PaymentCardCreateModel?
    @Published var didTapOnURL: URL? {
        didSet {
            if let url = didTapOnURL {
                presentPlanDocumentsModal(withUrl: url)
            }
        }
    }
    
    @State var keyboardHeight: CGFloat = 0

    var titleText: String?
    var descriptionText: String?
    let membershipPlan: CD_MembershipPlan?
    private var privacyPolicy: NSMutableAttributedString?
    private var termsAndConditions: NSMutableAttributedString?
    private let strings = PaymentCardScannerStrings()
    
    init(datasource: FormDataSource, title: String?, description: String?, membershipPlan: CD_MembershipPlan? = nil, addPaymentCardViewModel: AddPaymentCardViewModel? = nil) {
        self.datasource = datasource
        self.titleText = title
        self.descriptionText = description
        self.membershipPlan = membershipPlan
        self.addPaymentCardViewModel = addPaymentCardViewModel
        self.paymentCard = addPaymentCardViewModel?.paymentCard
    }
    
    var checkboxStackHeight: CGFloat {
        return datasource.checkboxes.count == 3 ? 150 : 100
    }
    
    func configureAttributedStrings() {
        for document in (membershipPlan?.account?.planDocuments) ?? [] {
            let planDocument = document as? CD_PlanDocument
            if planDocument?.name?.contains("policy") == true {
                if let urlString = planDocument?.url, let url = URL(string: urlString) {
                    privacyPolicy = HTMLParsingUtil.makeAttributedStringFromHTML(url: url)
                }
            }
            
            if planDocument?.name?.contains("conditions") == true {
                if let urlString = planDocument?.url, let url = URL(string: urlString) {
                    termsAndConditions = HTMLParsingUtil.makeAttributedStringFromHTML(url: url)
                }
            }
        }
    }
    
    func presentPlanDocumentsModal(withUrl url: URL) {
        if let text = url.absoluteString.contains("pp") ? privacyPolicy : termsAndConditions {
            let modalConfig = ReusableModalConfiguration(text: text, membershipPlan: membershipPlan)
            let viewController = ViewControllerFactory.makeReusableTemplateViewController(configuration: modalConfig)
            let navigationRequest = ModalNavigationRequest(viewController: viewController)
            Current.navigate.to(navigationRequest)
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
    
    func configurePaymentCard(field: FormField, value: String) {
        if field.fieldType == .paymentCardNumber {
            let type = PaymentCardType.type(from: value)
            addPaymentCardViewModel?.setPaymentCardType(type)
            addPaymentCardViewModel?.setPaymentCardFullPan(value)
        }
        
        if field.fieldType == .text { addPaymentCardViewModel?.setPaymentCardName(value) }
        paymentCard = addPaymentCardViewModel?.paymentCard
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

enum PickerType {
    case date
    case choice(data: [FormPickerData])
    case expiry
    case none
}
