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
    @Published var textFields: [Int: UITextField] = [:]
    @Published var textFieldClearButtonTapped: Bool?
    @Published var scrollViewOffsetForKeyboard: CGFloat = 0 {
        didSet {
            print("scrollViewOffsetForKeyboard: \(scrollViewOffsetForKeyboard)")
        }
    }
    @Published var formInputType: FormInputType = .none {
        didSet {
            setKeyboardHeight()
            print(keyboardHeight)
        }
    }

    var titleText: String?
    var descriptionText: String?
    var previousTextfieldValue = ""
    var scrollViewOffset: CGFloat = 0
    var selectedCellYOrigin: CGFloat = 0 {
        didSet {
            print("selectedCellYOrigin: \(selectedCellYOrigin)")
        }
    }
    let membershipPlan: CD_MembershipPlan?
    private let strings = PaymentCardScannerStrings()

    init(datasource: FormDataSource, title: String?, description: String?, membershipPlan: CD_MembershipPlan? = nil, addPaymentCardViewModel: AddPaymentCardViewModel? = nil) {
        self.datasource = datasource
        self.titleText = title
        self.descriptionText = description
        self.membershipPlan = membershipPlan
        self.addPaymentCardViewModel = addPaymentCardViewModel
        self.paymentCard = addPaymentCardViewModel?.paymentCard
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    var shouldShowTextfieldToolbar: Bool {
        if case .none = formInputType {
            return false
        }
        return keyboardHeight <= 0.0 ? false : true
    }
    
    var shouldShowInputToolbarSpacer: Bool {
        switch formInputType {
        case .keyboard, .secureEntry:
            return true
        default:
            return false
        }
    }
    
    @objc func handleKeyboardWillShow(_ notification: Notification) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else { return }

            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                let keyboardRectangle = keyboardFrame.cgRectValue
//                let keyboardHeight1 = keyboardRectangle.height
//                let visibleOffset = UIScreen.main.bounds.height - keyboardHeight1
//                print("keyboard height: \(keyboardHeight1)")
//                print("visible offset: \(visibleOffset)")
//                let cellVisibleOffset = self.selectedCellYOrigin
                
                self.keyboardHeight = keyboardRectangle.height
                self.formInputType = .keyboard

//                if cellVisibleOffset > visibleOffset {
////                    let actualOffset = self.scrollViewOffset
////                    let neededOffset = CGPoint(x: 0, y: Constants.offsetPadding + actualOffset + cellVisibleOffset - visibleOffset)
////                    self.stackScrollView.setContentOffset(neededOffset, animated: true)
//
////                    self.scrollViewOffsetForKeyboard = 150 + actualOffset + cellVisibleOffset - visibleOffset
//
//                    /// From iOS 14, we are seeing this method being called more often than we would like due to a notification trigger not only when the cell's text field is selected, but when typed into.
//                    /// We are resetting these values so that the existing behaviour will still work, whereby these values are updated from delegate methods when they should be, but when the notification is
//                    /// called from text input, these won't be updated and therefore will remain as 0.0, and won't fall into this if statement and won't update the content offset of the stack scroll view.
//                    self.selectedCellYOrigin = 0.0
////                    self.selectedCellHeight = 0.0
//                }
            }
        }
    }
    
    @objc func handleKeyboardWillHide(_ notification: Notification) {
        formInputType = .none
    }
    
    func setKeyboardHeight(height: CGFloat? = nil) {
        switch formInputType {
        case .keyboard, .secureEntry:
//            keyboardHeight = (height ?? 0)
            break
        case .date:
            if #available(iOS 14.0, *) {
                keyboardHeight = FormViewConstants.graphicalDatePickerHeight
            } else {
                keyboardHeight = FormViewConstants.datePickerHeight
            }
        case .choice:
            keyboardHeight = FormViewConstants.multipleChoicePickerHeight
        case .expiry:
            keyboardHeight = FormViewConstants.expiryDatePickerHeight
        case .none:
            keyboardHeight = 0
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
            self.datasource.checkFormValidity()
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
            viewModel.paymentCard = paymentCardCreateModel
            self.datasource = FormDataSource(paymentCardCreateModel, delegate: viewModel)
            self.datasource.checkFormValidity()
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
    case keyboard
    case secureEntry
    case none
}
