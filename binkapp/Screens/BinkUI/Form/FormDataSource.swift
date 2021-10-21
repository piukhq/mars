//
//  FormDataSource.swift
//  binkapp
//
//  Created by Max Woodhams on 14/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

protocol FormDataSourceDelegate: NSObjectProtocol {
    func formDataSource(_ dataSource: FormDataSource, changed value: String?, for field: FormField)
    func formDataSource(_ dataSource: FormDataSource, selected options: [Any], for field: FormField)
    func formDataSource(_ dataSource: FormDataSource, textField: UITextField, shouldChangeTo newValue: String?, in range: NSRange, for field: FormField) -> Bool
    func formDataSource(_ dataSource: FormDataSource, fieldDidExit: FormField)
    func formDataSource(_ dataSource: FormDataSource, checkboxUpdated: CheckboxView)
    func formDataSource(_ dataSource: FormDataSource, manualValidate field: FormField) -> Bool
    func formDataSourceShouldScrollToBottom(_ dataSource: FormDataSource)
    func formDataSourceShouldRefresh(_ dataSource: FormDataSource)
}

extension FormDataSourceDelegate {
    func formDataSource(_ dataSource: FormDataSource, changed value: String?, for field: FormField) {}
    func formDataSource(_ dataSource: FormDataSource, selected options: [Any], for field: FormField) {}
    func formDataSource(_ dataSource: FormDataSource, fieldDidExit: FormField) {}
    func formDataSource(_ dataSource: FormDataSource, checkboxUpdated: CheckboxView) {}
    func formDataSource(_ dataSource: FormDataSource, manualValidate field: FormField) -> Bool { return false }
    func formDataSourceShouldScrollToBottom(_ dataSource: FormDataSource) {}
    func formDataSourceShouldRefresh(_ dataSource: FormDataSource) {}
}

enum AccessForm {
    case magicLink
    case emailPassword
    case forgottenPassword
    case addEmail
    case termsAndConditions
    case success
}

enum FormType {
    case authAndAdd
    case addPaymentCard
    case login(accessForm: AccessForm)
}

class FormDataSource: NSObject, ObservableObject {
    struct PrefilledValue: Equatable {
        var commonName: FieldCommonName?
        var value: String?
    }
    
    typealias MultiDelegate = FormDataSourceDelegate & CheckboxViewDelegate
    
    private enum Constants {
        static let expiryYearsInTheFuture = 50
    }
    
    /// We need the data source to hold a reference to the plan for some forms so that we can pass it through delegates to other objects
    private(set) var membershipPlan: CD_MembershipPlan?
    
    @Published var fields: [FormField] = []
    @Published var formPurpose: FormPurpose?
    @Published var fullFormIsValid = false

    var formtype: FormType = .login(accessForm: .magicLink)
    var visibleFields: [FormField] {
        return fields.filter { !$0.hidden }
    }
    private(set) var checkboxes: [CheckboxSwiftUIView] = []
    private var selectedCheckboxIndex = 0
    weak var delegate: MultiDelegate?
    
    func checkFormValidity() {
        let formFieldsValid = fields.allSatisfy({ $0.isValid() })
        var checkboxesValid = true
        checkboxes.forEach { checkbox in
            if checkbox.columnKind == FormField.ColumnKind.planDocument || checkbox.columnKind == FormField.ColumnKind.none {
                if !checkbox.isValid {
                    checkboxesValid = false
                }
            }
        }
        
        fullFormIsValid = formFieldsValid && checkboxesValid
    }
    
    func currentFieldValues() -> [String: String] {
        var values: [String: String] = [:]
        fields.forEach { values[$0.title.lowercased()] = $0.value }
        
        return values
    }
}

// MARK: - Add Payment Card
extension FormDataSource {
    convenience init(_ paymentCardModel: PaymentCardCreateModel, delegate: MultiDelegate? = nil) {
        self.init()
        self.delegate = delegate
        formtype = .addPaymentCard
        setupFields(with: paymentCardModel)
    }
    
    private func setupFields<T>(with model: T) where T: PaymentCardCreateModel {
        let updatedBlock: FormField.ValueUpdatedBlock = { [weak self] field, newValue in
            guard let self = self else { return }
            self.delegate?.formDataSource(self, changed: newValue, for: field)
        }

        let shouldChangeBlock: FormField.TextFieldShouldChange = { [weak self] (field, textField, range, newValue) in
            guard let self = self, let delegate = self.delegate else { return true }
            return delegate.formDataSource(self, textField: textField, shouldChangeTo: newValue, in: range, for: field)
        }

        let pickerUpdatedBlock: FormField.PickerUpdatedBlock = { [weak self] field, options in
            guard let self = self else { return }
            self.delegate?.formDataSource(self, selected: options, for: field)
        }

        let fieldExitedBlock: FormField.FieldExitedBlock = { [weak self] field in
            guard let self = self else { return }
            self.checkFormValidity()
            self.delegate?.formDataSource(self, fieldDidExit: field)
        }

        let manualValidateBlock: FormField.ManualValidateBlock = { [weak self] field in
            guard let self = self, let delegate = self.delegate else { return false }
            return delegate.formDataSource(self, manualValidate: field)
        }
        
        // Card Number
        
        let cardNumberField = FormField(
            title: "Card number",
            placeholder: "xxxx xxxx xxxx xxxx",
            validation: nil,
            fieldType: .paymentCardNumber,
            updated: updatedBlock,
            shouldChange: shouldChangeBlock,
            fieldExited: fieldExitedBlock,
            forcedValue: model.fullPan,
            fieldCommonName: .cardNumber
        )
        
        
        let monthData = Calendar.current.monthSymbols.enumerated().compactMap { index, _ in
            FormPickerData(String(format: "%02d", index + 1), backingData: index + 1)
        }
        
        let yearValue = Calendar.current.component(.year, from: Date())
        let yearData = Array(yearValue...yearValue + Constants.expiryYearsInTheFuture).compactMap { FormPickerData("\($0)", backingData: $0) }

        let expiryField = FormField(
            title: "Expiry",
            placeholder: "MM/YY",
            validation: "^(0[1-9]|1[012])[\\/](19|20)\\d\\d$",
            validationErrorMessage: "Invalid expiry date",
            fieldType: .expiry(months: monthData, years: yearData),
            updated: updatedBlock,
            shouldChange: shouldChangeBlock,
            fieldExited: fieldExitedBlock,
            pickerSelected: pickerUpdatedBlock,
            manualValidate: manualValidateBlock,
            /// It's fine to force unwrap here, as we are already guarding against the values being nil and we don't want to provide default values
            /// We will never reach the force unwrapping if either value is nil
            forcedValue: model.month == nil || model.year == nil ? nil : "\(String(format: "%02d", model.month ?? 0))/\(model.year ?? 0)"
        )

        let nameOnCardField = FormField(
            title: "Name on card",
            placeholder: "J Appleseed",
            validation: "^(((?=.{1,}$)[A-Za-z\\-\\u00C0-\\u00FF' ])+\\s*)$",
            fieldType: .text,
            updated: updatedBlock,
            shouldChange: shouldChangeBlock,
            fieldExited: fieldExitedBlock
        )
        
        fields = [cardNumberField, expiryField, nameOnCardField]
    }
}

// MARK: - Add And Auth
extension FormDataSource {
    convenience init(authAdd membershipPlan: CD_MembershipPlan, formPurpose: FormPurpose, delegate: MultiDelegate? = nil, prefilledValues: [PrefilledValue]? = nil) {
        self.init()
        self.delegate = delegate
        self.formPurpose = formPurpose
        self.membershipPlan = membershipPlan
        formtype = .authAndAdd
        setupFields(with: membershipPlan, formPurpose: formPurpose, prefilledValues: prefilledValues)
    }
    
    private func setupFields<T>(with model: T, formPurpose: FormPurpose, prefilledValues: [PrefilledValue]?) where T: CD_MembershipPlan {
        let updatedBlock: FormField.ValueUpdatedBlock = { [weak self] field, newValue in
            guard let self = self else { return }
            self.delegate?.formDataSource(self, changed: newValue, for: field)
        }
        
        let shouldChangeBlock: FormField.TextFieldShouldChange = { [weak self] (field, textField, range, newValue) in
            guard let self = self, let delegate = self.delegate else { return true }
            return delegate.formDataSource(self, textField: textField, shouldChangeTo: newValue, in: range, for: field)
        }
        
        let pickerUpdatedBlock: FormField.PickerUpdatedBlock = { [weak self] field, options in
            guard let self = self else { return }
            self.delegate?.formDataSource(self, selected: options, for: field)
        }
        
        let fieldExitedBlock: FormField.FieldExitedBlock = { [weak self] field in
            guard let self = self else { return }
            self.checkFormValidity()
//            self.delegate?.formDataSource(self, fieldDidExit: field)
        }
        
        let dataSourceRefreshBlock: FormField.DataSourceRefreshBlock = { [weak self] in
            guard let self = self else { return }
            self.delegate?.formDataSourceShouldRefresh(self)
        }

        if case .addFromScanner = formPurpose {
            model.account?.formattedAddFields(omitting: [.cardNumber])?.sorted(by: { $0.order.intValue < $1.order.intValue }).forEach { field in
                if field.fieldInputType == .checkbox {
                    let attributedString = NSMutableAttributedString(string: field.fieldDescription ?? "", attributes: [.font: UIFont.bodyTextSmall])
                    let checkbox = CheckboxSwiftUIView(attributedText: attributedString, columnName: field.column ?? "", columnKind: .add, checkValidity: checkFormValidity)
                    checkboxes.append(checkbox)
                } else {
                    fields.append(
                        FormField(
                            title: field.column ?? "",
                            placeholder: field.fieldDescription ?? "",
                            validation: field.validation,
                            fieldType: FormField.FieldInputType.fieldInputType(for: field.fieldInputType, commonName: FieldCommonName(rawValue: field.commonName ?? ""), choices: field.choicesArray),
                            updated: updatedBlock,
                            shouldChange: shouldChangeBlock,
                            fieldExited: fieldExitedBlock,
                            pickerSelected: pickerUpdatedBlock,
                            columnKind: .add,
                            forcedValue: prefilledValues?.first(where: { $0.commonName?.rawValue == field.commonName })?.value,
                            isReadOnly: field.fieldCommonName == .barcode,
                            fieldCommonName: field.fieldCommonName,
                            alternatives: field.alternativeCommonNames(),
                            dataSourceRefreshBlock: dataSourceRefreshBlock
                        )
                    )
                }
            }
        }
        
        if formPurpose == .add || formPurpose == .addFailed || formPurpose == .ghostCard {
            model.account?.formattedAddFields(omitting: [.barcode])?.sorted(by: { $0.order.intValue < $1.order.intValue }).forEach { field in
                if field.fieldInputType == .checkbox {
                    let attributedString = NSMutableAttributedString(string: field.fieldDescription ?? "", attributes: [.font: UIFont.bodyTextSmall])
                    let checkbox = CheckboxSwiftUIView(attributedText: attributedString, columnName: field.column ?? "", columnKind: .add, checkValidity: checkFormValidity)
                    checkboxes.append(checkbox)
                } else {
                    fields.append(
                        FormField(
                            title: field.column ?? "",
                            placeholder: field.fieldDescription ?? "",
                            validation: field.validation,
                            fieldType: FormField.FieldInputType.fieldInputType(for: field.fieldInputType, commonName: FieldCommonName(rawValue: field.commonName ?? ""), choices: field.choicesArray),
                            updated: updatedBlock,
                            shouldChange: shouldChangeBlock,
                            fieldExited: fieldExitedBlock,
                            pickerSelected: pickerUpdatedBlock,
                            columnKind: .add,
                            forcedValue: prefilledValues?.first(where: { $0.commonName?.rawValue == field.commonName })?.value,
                            fieldCommonName: field.fieldCommonName,
                            alternatives: field.alternativeCommonNames(),
                            dataSourceRefreshBlock: dataSourceRefreshBlock,
                            hidden: (formPurpose == .addFailed && !(membershipPlan?.isPLL ?? false)) ? true : false
                        )
                    )
                }
            }
        }
        
        if case .addFromScanner = formPurpose {
            model.account?.formattedAuthFields?.sorted(by: { $0.order.intValue < $1.order.intValue }).forEach { field in
                if field.fieldInputType == .checkbox {
                    let attributedString = NSMutableAttributedString(string: field.fieldDescription ?? "", attributes: [.font: UIFont.bodyTextSmall])
                    let checkbox = CheckboxSwiftUIView(attributedText: attributedString, columnName: field.column ?? "", columnKind: .auth, checkValidity: checkFormValidity)
                    checkboxes.append(checkbox)
                } else {
                    fields.append(
                        FormField(
                            title: field.column ?? "",
                            placeholder: field.fieldDescription ?? "",
                            validation: field.validation,
                            fieldType: FormField.FieldInputType.fieldInputType(for: field.fieldInputType, commonName: field.fieldCommonName, choices: field.choicesArray),
                            updated: updatedBlock,
                            shouldChange: shouldChangeBlock,
                            fieldExited: fieldExitedBlock,
                            pickerSelected: pickerUpdatedBlock,
                            columnKind: .auth,
                            forcedValue: prefilledValues?.first(where: { $0.commonName?.rawValue == field.commonName })?.value,
                            isReadOnly: field.fieldCommonName == .barcode,
                            fieldCommonName: field.fieldCommonName
                        )
                    )
                }
            }
            
            // Local Points Collection
            /// LPC merchants won't have auth fields returned in the API response; instead we get them from remote config
            /// Add them to the fields here. Their values will never be sent to Bink in the POST request.
            if let plan = membershipPlan, let lpcAuthFields = plan.lpcAuthFields {
                lpcAuthFields.forEach { field in
                    guard let fieldType = field.type else { return }
                    guard let fieldCommonName = field.commonName else { return }

                    fields.append(
                        FormField(
                            title: field.column ?? "",
                            placeholder: field.fieldDescription ?? "",
                            validation: field.validation,
                            fieldType: FormField.FieldInputType.fieldInputType(for: InputType(rawValue: fieldType), commonName: FieldCommonName(rawValue: fieldCommonName), choices: field.choices),
                            updated: updatedBlock,
                            shouldChange: shouldChangeBlock,
                            fieldExited: fieldExitedBlock,
                            pickerSelected: pickerUpdatedBlock,
                            columnKind: .lpcAuth,
                            forcedValue: prefilledValues?.first(where: { $0.commonName?.rawValue == field.commonName })?.value,
                            fieldCommonName: FieldCommonName(rawValue: fieldCommonName)
                        )
                    )
                }
            }
        } else if formPurpose != .signUp && formPurpose != .signUpFailed && formPurpose != .ghostCard && formPurpose != .patchGhostCard {
            model.account?.formattedAuthFields?.sorted(by: { $0.order.intValue < $1.order.intValue }).forEach { field in
                if field.fieldInputType == .checkbox {
                    let attributedString = NSMutableAttributedString(string: field.fieldDescription ?? "", attributes: [.font: UIFont.bodyTextSmall])
                    let checkbox = CheckboxSwiftUIView(attributedText: attributedString, columnName: field.column ?? "", columnKind: .auth, checkValidity: checkFormValidity)
                    checkboxes.append(checkbox)
                } else {
                    fields.append(
                        FormField(
                            title: field.column ?? "",
                            placeholder: field.fieldDescription ?? "",
                            validation: field.validation,
                            fieldType: FormField.FieldInputType.fieldInputType(for: field.fieldInputType, commonName: field.fieldCommonName, choices: field.choicesArray),
                            updated: updatedBlock,
                            shouldChange: shouldChangeBlock,
                            fieldExited: fieldExitedBlock,
                            pickerSelected: pickerUpdatedBlock,
                            columnKind: .auth,
                            forcedValue: prefilledValues?.first(where: { $0.commonName?.rawValue == field.commonName })?.value,
                            fieldCommonName: field.fieldCommonName
                        )
                    )
                }
            }

            // Local Points Collection
            /// LPC merchants won't have auth fields returned in the API response; instead we get them from remote config
            /// Add them to the fields here. Their values will never be sent to Bink in the POST request.
            if let plan = membershipPlan, let lpcAuthFields = plan.lpcAuthFields {
                lpcAuthFields.forEach { field in
                    guard let fieldType = field.type else { return }
                    guard let fieldCommonName = field.commonName else { return }

                    fields.append(
                        FormField(
                            title: field.column ?? "",
                            placeholder: field.fieldDescription ?? "",
                            validation: field.validation,
                            fieldType: FormField.FieldInputType.fieldInputType(for: InputType(rawValue: fieldType), commonName: FieldCommonName(rawValue: fieldCommonName), choices: field.choices),
                            updated: updatedBlock,
                            shouldChange: shouldChangeBlock,
                            fieldExited: fieldExitedBlock,
                            pickerSelected: pickerUpdatedBlock,
                            columnKind: .lpcAuth,
                            forcedValue: prefilledValues?.first(where: { $0.commonName?.rawValue == field.commonName })?.value,
                            fieldCommonName: FieldCommonName(rawValue: fieldCommonName)
                        )
                    )
                }
            }
        }
        
        if formPurpose == .signUp || formPurpose == .signUpFailed {
            model.account?.formattedEnrolFields?.sorted(by: { $0.order.intValue < $1.order.intValue }).forEach { field in
                if field.fieldInputType == .checkbox {
                    let attributedString = NSMutableAttributedString(string: field.fieldDescription ?? "", attributes: [.font: UIFont.bodyTextSmall])
                    let checkbox = CheckboxSwiftUIView(attributedText: attributedString, columnName: field.column ?? "", columnKind: .enrol, checkValidity: checkFormValidity)
                    checkboxes.append(checkbox)
                } else {
                    fields.append(
                        FormField(
                            title: field.column ?? "",
                            placeholder: field.fieldDescription ?? "",
                            validation: field.validation,
                            fieldType: FormField.FieldInputType.fieldInputType(for: field.fieldInputType, commonName: field.fieldCommonName, choices: field.choicesArray),
                            updated: updatedBlock,
                            shouldChange: shouldChangeBlock,
                            fieldExited: fieldExitedBlock,
                            columnKind: .enrol,
                            forcedValue: prefilledValues?.first(where: { $0.commonName?.rawValue == field.commonName })?.value,
                            fieldCommonName: field.fieldCommonName
                        )
                    )
                }
            }
        }
        
        if formPurpose == .ghostCard || formPurpose == .patchGhostCard {
            model.account?.formattedRegistrationFields?.sorted(by: { $0.order.intValue < $1.order.intValue }).forEach { field in
                if field.fieldInputType == .checkbox {
                    let attributedString = NSMutableAttributedString(string: field.fieldDescription ?? "", attributes: [.font: UIFont.bodyTextSmall])
                    let checkbox = CheckboxSwiftUIView(attributedText: attributedString, columnName: field.column ?? "", columnKind: .register, checkValidity: checkFormValidity)
                    checkboxes.append(checkbox)
                } else {
                    fields.append(
                        FormField(
                            title: field.column ?? "",
                            placeholder: field.fieldDescription ?? "",
                            validation: field.validation,
                            fieldType: FormField.FieldInputType.fieldInputType(for: field.fieldInputType, commonName: field.fieldCommonName, choices: field.choicesArray),
                            updated: updatedBlock,
                            shouldChange: shouldChangeBlock,
                            fieldExited: fieldExitedBlock,
                            columnKind: .register,
                            forcedValue: prefilledValues?.first(where: { $0.commonName?.rawValue == field.commonName })?.value,
                            fieldCommonName: field.fieldCommonName
                            )
                    )
                }
            }
        }
        
        checkboxes.append(contentsOf: getPlanDocumentsCheckboxes(journey: formPurpose.planDocumentDisplayMatching, membershipPlan: model))
    }
    
    private func getPlanDocumentsCheckboxes(journey: PlanDocumentDisplayModel, membershipPlan: CD_MembershipPlan) -> [CheckboxSwiftUIView] {
        var checkboxes: [CheckboxSwiftUIView] = []

        membershipPlan.account?.formattedPlanDocuments?.forEach { field in
            guard field.formattedDisplay.contains(where: { $0.value == journey.rawValue }) else { return }
            let url = URL(string: field.url ?? "")
            let fieldText = (field.documentDescription ?? "") + " " + (field.name ?? "")
            let attributedString = NSMutableAttributedString(string: fieldText, attributes: [.font: UIFont.bodyTextSmall])

            if field.checkbox?.boolValue == true {
                let checkbox = CheckboxSwiftUIView(text: "", attributedText: attributedString, columnName: field.name, columnKind: .planDocument, url: url, membershipPlan: membershipPlan, checkValidity: checkFormValidity)
                checkboxes.append(checkbox)
            } else {
                let checkbox = CheckboxSwiftUIView(text: "", attributedText: attributedString, columnName: field.name ?? "", columnKind: .planDocument, url: url, hideCheckbox: true, membershipPlan: membershipPlan, checkValidity: checkFormValidity)
                checkboxes.append(checkbox)
            }
        }

        return checkboxes
    }
}

// MARK: - Login

extension FormDataSource {
    convenience init(accessForm: AccessForm, prefilledValues: [PrefilledValue]? = nil) {
        self.init()
        self.delegate = delegate
        formtype = .login(accessForm: accessForm)
        setupFields(accessForm: accessForm, prefilledValues: prefilledValues)
    }
    
    private func setupFields(accessForm: AccessForm, prefilledValues: [PrefilledValue]?) {
        let updatedBlock: FormField.ValueUpdatedBlock = { [weak self] field, newValue in
            guard let self = self else { return }
            self.delegate?.formDataSource(self, changed: newValue, for: field)
        }
        
        let shouldChangeBlock: FormField.TextFieldShouldChange = { [weak self] (field, textField, range, newValue) in
            guard let self = self, let delegate = self.delegate else { return true }
            return delegate.formDataSource(self, textField: textField, shouldChangeTo: newValue, in: range, for: field)
        }
        
        let fieldExitedBlock: FormField.FieldExitedBlock = { [weak self] field in
            guard let self = self else { return }
            self.checkFormValidity()
//            self.delegate?.formDataSource(self, fieldDidExit: field)
        }
        
        // Email
        
        if accessForm != .termsAndConditions && accessForm != .success {
            let emailField = FormField(
                title: L10n.accessFormEmailTitle,
                placeholder: L10n.accessFormEmailPlaceholder,
                validation: "^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$",
                validationErrorMessage: L10n.accessFormEmailValidation,
                fieldType: .email,
                updated: updatedBlock,
                shouldChange: shouldChangeBlock,
                fieldExited: fieldExitedBlock,
                forcedValue: prefilledValues?.first(where: { $0.commonName == .email })?.value,
                fieldCommonName: .email
            )
            
            fields.append(emailField)
        }
        
        // Password
        
        if accessForm == .emailPassword {
            let passwordField = FormField(
                title: L10n.accessFormPasswordTitle,
                placeholder: L10n.accessFormPasswordPlaceholder,
                validation: "^(?=.*\\d)(?=.*[a-z])(?=.*[A-Z]).{8,30}$",
                validationErrorMessage: L10n.accessFormPasswordValidation,
                fieldType: .sensitive,
                updated: updatedBlock,
                shouldChange: shouldChangeBlock,
                fieldExited: fieldExitedBlock
            )
            
            fields.append(passwordField)
        }
        
        let customBundleClientEnabled = Current.userDefaults.bool(forDefaultsKey: .allowCustomBundleClientOnLogin)
        
        if !Current.isReleaseTypeBuild && customBundleClientEnabled {
            let bundleIDField = FormField(
                title: "Bundle ID",
                placeholder: "Fam, your bundle ID",
                validation: nil,
                fieldType: .text,
                updated: updatedBlock,
                shouldChange: shouldChangeBlock,
                fieldExited: fieldExitedBlock
            )
            
            let clientIDField = FormField(
                title: "Client ID",
                placeholder: "Lad, your client ID",
                validation: nil,
                fieldType: .text,
                updated: updatedBlock,
                shouldChange: shouldChangeBlock,
                fieldExited: fieldExitedBlock
            )
            
            fields.append(clientIDField)
            fields.append(bundleIDField)
        }
        
        let attributedTCs = NSMutableAttributedString(string: L10n.tandcsTitle + "\n" + L10n.tandcsDescription, attributes: [.font: UIFont.bodyTextSmall])
        let baseTCs = NSString(string: attributedTCs.string)
        let tcsRange = baseTCs.range(of: L10n.tandcsLink)
        let privacyPolicyRange = baseTCs.range(of: L10n.ppolicyLink)
        attributedTCs.addAttributes([.link: "https://bink.com/terms-and-conditions/"], range: tcsRange)
        attributedTCs.addAttributes([.link: "https://bink.com/privacy-policy/"], range: privacyPolicyRange)
        
        let termsAndConditions = CheckboxSwiftUIView(text: "", attributedText: attributedTCs, columnName: L10n.tandcsLink, columnKind: .none, checkValidity: checkFormValidity)
        
        let attributedMarketing = NSMutableAttributedString(string: L10n.marketingTitle + "\n" + L10n.preferencesPrompt, attributes: [.font: UIFont.bodyTextSmall])
        let baseMarketing = NSString(string: attributedMarketing.string)
        let rewardsRange = baseMarketing.range(of: L10n.preferencesPromptHighlightRewards)
        let offersRange = baseMarketing.range(of: L10n.preferencesPromptHighlightOffers)
        let updatesRange = baseMarketing.range(of: L10n.preferencesPromptHighlightUpdates)
        
        let attributes: [NSAttributedString.Key: Any] = [.font: UIFont(name: "NunitoSans-ExtraBold", size: 14.0) ?? UIFont()]
        
        attributedMarketing.addAttributes(attributes, range: rewardsRange)
        attributedMarketing.addAttributes(attributes, range: offersRange)
        attributedMarketing.addAttributes(attributes, range: updatesRange)
        
        let marketing = CheckboxSwiftUIView(attributedText: attributedMarketing, columnName: "marketing-bink", columnKind: .userPreference, optional: true, checkValidity: checkFormValidity)
        
        if accessForm == .termsAndConditions {
            checkboxes.append(termsAndConditions)
            checkboxes.append(marketing)
        }
        
        if accessForm == .magicLink {
            checkboxes.append(termsAndConditions)
        }
//        
//        if accessForm == .success {
//            checkboxes.append(marketingCheckbox)
//        }
    }
    
    private func hyperlinkString(_ text: String, hyperlink: String) -> NSAttributedString {
        let attributed = NSMutableAttributedString(string: text, attributes: [.font: UIFont.bodyTextSmall])
        let countMinusHyperlinkString = text.count - hyperlink.count
        attributed.addAttributes([.underlineStyle: NSUnderlineStyle.single.rawValue, .foregroundColor: UIColor.blueAccent, .font: UIFont.checkboxText], range: NSMakeRange(countMinusHyperlinkString, hyperlink.count))
                
        return attributed
    }
}
