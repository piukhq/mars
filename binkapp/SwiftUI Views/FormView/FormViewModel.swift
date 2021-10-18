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
    @Published var pickerData = FormPickerData("", backingData: 0)
    @Published var addPaymentCardViewModel: AddPaymentCardViewModel?
    @Published var paymentCard: PaymentCardCreateModel?
    @Published var textFields: [Int: UITextField] = [:]
    @Published var textFieldClearButtonTapped: Bool?
    @Published var vStackInsets = FormViewConstants.vStackInsets
    @Published var scrollViewOffsetForKeyboard: CGFloat = 0
    @Published var scrollToTextfieldID: Int?
    @Published var formInputType: FormInputType = .none {
        didSet {
            setKeyboardHeight()

            if #available(iOS 14.0, *) {
                if case .none = formInputType {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                        withAnimation {
                            self?.vStackInsets = FormViewConstants.vStackInsets
                        }
                    }
                }
            } else {
                handleKeyboardOffset()
            }
        }
    }

    var titleText: String?
    var descriptionText: String?
    var previousTextfieldValue = ""
    var didLayoutViews = false
    var scrollViewOffset: CGFloat = 0
    var selectedTextfieldYOrigin: CGFloat = 0
    var selectedTextfieldID = 0
    let membershipPlan: CD_MembershipPlan?
    private let strings = PaymentCardScannerStrings()
    var keyboardHeight: CGFloat = 0

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
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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
//        if #available(iOS 14.0, *) {} else {
            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                let keyboardRectangle = keyboardFrame.cgRectValue
                self.keyboardHeight = keyboardRectangle.height
                self.formInputType = .keyboard
                self.scrollToTextfieldID = selectedTextfieldID
            }
//        }
    }
    
    @objc func handleKeyboardWillHide(_ notification: Notification) {
        formInputType = .none
    }

    private func setKeyboardHeight() {
        switch formInputType {
        case .keyboard, .secureEntry:
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
    
    func handleKeyboardOffset() {
        withAnimation {
            if case .none = formInputType {
                vStackInsets = FormViewConstants.vStackInsets
                scrollViewOffsetForKeyboard = 0
                return
            } else {
                let screenHeight = UIScreen.main.bounds.height
                let visibleOffset = screenHeight - (keyboardHeight + FormViewConstants.inputToolbarHeight)
                if selectedTextfieldYOrigin > visibleOffset {
                    let distanceFromSelectedTextfieldToBottomOfScreen = screenHeight - selectedTextfieldYOrigin
                    let distanceFromSelectedTextfieldToTopOfKeyboard = keyboardHeight - distanceFromSelectedTextfieldToBottomOfScreen
                    let neededOffset = distanceFromSelectedTextfieldToTopOfKeyboard + FormViewConstants.scrollViewOffsetBuffer
                    var iOS13Buffer: CGFloat = 0.0
                    if #available(iOS 14.0, *) {} else {
                        iOS13Buffer += 65
                    }

                    if case .keyboard = formInputType {
                        if scrollViewOffsetForKeyboard != 0.0 {
                            // Next button on keyboard tapped, add new offset to previous offset
                            let combinedOffsets = neededOffset + scrollViewOffsetForKeyboard
                            if combinedOffsets > keyboardHeight {
                                scrollViewOffsetForKeyboard = keyboardHeight - FormViewConstants.scrollViewOffsetBuffer
                            } else {
                                scrollViewOffsetForKeyboard = combinedOffsets
                            }
                        } else {
                            // Textfield has been selected by user
                            scrollViewOffsetForKeyboard = neededOffset + iOS13Buffer
                            vStackInsets = FormViewConstants.vStackInsetsForKeyboard
                        }
                    } else {
                        // Pickers
                        scrollViewOffsetForKeyboard = neededOffset + FormViewConstants.inputToolbarHeight + iOS13Buffer
                    }
                } else {
                    // Selected textfield is visible, but still add padding to vStack so user can scroll to see content hidden by keyboard
                    vStackInsets = FormViewConstants.vStackInsetsForKeyboard
                }
            }
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
                pickerData = FormPickerData(pickerOne, backingData: 1)
            } else if pickerOne.isEmpty {
                pickerData = FormPickerData(pickerTwo, backingData: 1)
            } else {
                pickerData = FormPickerData(pickerOne + "/" + pickerTwo, backingData: 2)
            }
        default:
            pickerData = FormPickerData(pickerOne, backingData: 1)
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
