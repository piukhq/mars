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
}

extension FormDataSourceDelegate {
    func formDataSource(_ dataSource: FormDataSource, changed value: String?, for field: FormField) {}
    func formDataSource(_ dataSource: FormDataSource, selected options: [Any], for field: FormField) {}
    func formDataSource(_ dataSource: FormDataSource, fieldDidExit: FormField) {}
    func formDataSource(_ dataSource: FormDataSource, checkboxUpdated: CheckboxView) {}
    func formDataSource(_ dataSource: FormDataSource, manualValidate field: FormField) -> Bool {
        return false
    }
}

enum AccessForm {
    case login
    case register
    case forgottenPassword
    case addEmail
    case socialTermsAndConditions
}

class FormDataSource: NSObject {
    
    typealias MultiDelegate = FormDataSourceDelegate & CheckboxViewDelegate
    
    private struct Constants {
        static let expiryYearsInTheFuture = 50
    }
    
    private(set) var fields = [FormField]()
    private(set) var checkboxes = [CheckboxView]()
    weak var delegate: MultiDelegate?
    
    var fullFormIsValid: Bool {
        let formFieldsValid = fields.reduce(true, { $0 && $1.isValid() })
        var checkboxesValid = true
        checkboxes.forEach { checkbox in
            if checkbox.columnKind == FormField.ColumnKind.planDocument || checkbox.columnKind == FormField.ColumnKind.none {
                if !checkbox.isValid {
                    checkboxesValid = false
                }
            }
        }
        
        return formFieldsValid && checkboxesValid
    }
    
    func currentFieldValues() -> [String: String] {
        var values = [String: String]()
        fields.forEach { values[$0.title.lowercased()] = $0.value }
        
        return values
    }
}

// MARK: - Add Payment Card
extension FormDataSource {
    convenience init(_ paymentCardModel: PaymentCardCreateModel, delegate: MultiDelegate? = nil) {
        self.init()
        self.delegate = delegate
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
            fieldType: .cardNumber,
            updated: updatedBlock,
            shouldChange: shouldChangeBlock,
            fieldExited: fieldExitedBlock
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
            manualValidate: manualValidateBlock)

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
    convenience init(authAdd membershipPlan: CD_MembershipPlan, formPurpose: FormPurpose, delegate: MultiDelegate? = nil) {
        self.init()
        self.delegate = delegate
        setupFields(with: membershipPlan, formPurpose: formPurpose)
    }
    
    private func setupFields<T>(with model: T, formPurpose: FormPurpose) where T: CD_MembershipPlan {
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
            self.delegate?.formDataSource(self, fieldDidExit: field)
        }
        
        if formPurpose == .login || formPurpose == .loginFailed || formPurpose == .ghostCard {
            model.account?.formattedAddFields?.sorted(by: { $0.order.intValue < $1.order.intValue }).forEach { field in
                if field.fieldInputType == .checkbox {
                    let checkbox = CheckboxView(frame: .zero)
                    checkbox.configure(title: field.fieldDescription ?? "", columnName: field.column ?? "", columnKind: .add, delegate: self)
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
                            columnKind: .add
                        )
                    )
                }
            }
        }
        
        if formPurpose != .signUp && formPurpose != .ghostCard {
            model.account?.formattedAuthFields?.sorted(by: { $0.order.intValue < $1.order.intValue }).forEach { field in
                if field.fieldInputType == .checkbox {
                    let checkbox = CheckboxView(frame: .zero)
                    checkbox.configure(title: field.fieldDescription ?? "", columnName: field.column ?? "", columnKind: .auth, delegate: self)
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
                            columnKind: .auth
                        )
                    )
                }
            }
        }
        
        
        if formPurpose == .signUp {
            model.account?.formattedEnrolFields?.sorted(by: { $0.order.intValue < $1.order.intValue }).forEach { field in
                if field.fieldInputType == .checkbox {
                    let checkbox = CheckboxView(frame: .zero)
                    checkbox.configure(title: field.fieldDescription ?? "", columnName: field.column ?? "", columnKind: .enrol, delegate: self)
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
                            forcedValue: model.isPLR && field.commonName == FieldCommonName.email.rawValue ? Current.userManager.currentEmailAddress : nil
                        )
                    )
                }
            }
        }
        
        if formPurpose == .ghostCard {
            model.account?.formattedRegistrationFields?.sorted(by: { $0.order.intValue < $1.order.intValue }).forEach { field in
                if field.fieldInputType == .checkbox {
                    let checkbox = CheckboxView(frame: .zero)
                    checkbox.configure(title: field.fieldDescription ?? "", columnName: field.column ?? "", columnKind: .register, delegate: self)
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
                            columnKind: .register
                            )
                    )
                }
            }
        }
        
        checkboxes.append(contentsOf: getPlanDocumentsCheckboxes(journey: formPurpose.planDocumentDisplayMatching, membershipPlan: model))
    }
    
    private func getPlanDocumentsCheckboxes(journey: PlanDocumentDisplayModel, membershipPlan: CD_MembershipPlan) -> [CheckboxView] {
        var checkboxes = [CheckboxView]()
        
        membershipPlan.account?.formattedPlanDocuments?.forEach { field in
                        
            let displayFields = field.formattedDisplay
            
            guard displayFields.contains(where: { $0.value == journey.rawValue }) else { return }
        
            let checkbox = CheckboxView(frame: .zero)
            
            let url = URL(string: field.url ?? "")
            let fieldText = (field.documentDescription ?? "") + " " + (field.name ?? "")
            
            if field.checkbox?.boolValue == true {
                checkbox.configure(title: fieldText, columnName: field.name ?? "", columnKind: .planDocument, url: url, delegate: self)
            } else {
                //If we don't want a checkbox, we don't need a delegate for it, so we will hide the checkbox by checking if we have a delegate or not
                checkbox.configure(title: fieldText, columnName: field.name ?? "", columnKind: .planDocument, url: url, delegate: nil)
            }
            checkboxes.append(checkbox)
        }
        
        return checkboxes
    }
}

//MARK: - Login

extension FormDataSource {
    convenience init(accessForm: AccessForm) {
        self.init()
        self.delegate = delegate
        setupFields(accessForm: accessForm)
    }
    
    private func setupFields(accessForm: AccessForm) {
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
            self.delegate?.formDataSource(self, fieldDidExit: field)
        }
        
        // Email
        
        if accessForm != .socialTermsAndConditions {
            let emailField = FormField(
                title: "access_form_email_title".localized,
                placeholder: "access_form_email_placeholder".localized,
                validation: "^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$",
                validationErrorMessage: "access_form_email_validation".localized,
                fieldType: .email,
                updated: updatedBlock,
                shouldChange: shouldChangeBlock,
                fieldExited: fieldExitedBlock
            )
            
            fields.append(emailField)
        }
        
        // Password
        
        if accessForm == .login || accessForm == .register {
            let passwordField = FormField(
                title: "access_form_password_title".localized,
                placeholder: "access_form_password_placeholder".localized,
                validation: "^(?=.*\\d)(?=.*[a-z])(?=.*[A-Z]).{8,30}$",
                validationErrorMessage: "access_form_password_validation".localized,
                fieldType: .sensitive,
                updated: updatedBlock,
                shouldChange: shouldChangeBlock,
                fieldExited: fieldExitedBlock
            )
            
            fields.append(passwordField)
        }
        
        if accessForm == .register {
            let manualValidation: FormField.ManualValidateBlock = { [weak self] field in
                guard let self = self, let delegate = self.delegate else { return false }
                return delegate.formDataSource(self, manualValidate: field)
            }
            
            let confirmPasswordField = FormField(
                title: "access_form_confirm_password_title".localized,
                placeholder: "access_form_confirm_password_placeholder".localized,
                validation: nil,
                validationErrorMessage: "access_form_confirm_password_validation".localized,
                fieldType: .confirmPassword,
                updated: updatedBlock,
                shouldChange: shouldChangeBlock,
                fieldExited: fieldExitedBlock,
                manualValidate: manualValidation
            )
            
            fields.append(confirmPasswordField)
        }
        
        if accessForm == .socialTermsAndConditions || accessForm == .register {
            let termsAndConditions = CheckboxView(frame: .zero)
            termsAndConditions.configure(title: "tandcs_title".localized, columnName: "tandcs_link".localized, columnKind: .none, url: URL(string: "https://bink.com/terms-and-conditions/"), delegate: self)
            checkboxes.append(termsAndConditions)
            
            let privacyPolicy = CheckboxView(frame: .zero)
            privacyPolicy.configure(title: "ppolicy_title".localized, columnName: "ppolicy_link".localized, columnKind: .none, url: URL(string: "https://bink.com/privacy-policy/"), delegate: self)
            checkboxes.append(privacyPolicy)
            
            let marketingCheckbox = CheckboxView(frame: .zero)
            marketingCheckbox.configure(title: "marketing_title".localized, columnName: "marketing-bink", columnKind: .userPreference, delegate: self, optional: true)
            checkboxes.append(marketingCheckbox)
        }
    }
    
    private func hyperlinkString(_ text: String, hyperlink: String) -> NSAttributedString {
        let attributed = NSMutableAttributedString(string: text, attributes: [.font : UIFont.bodyTextSmall])
        let countMinusHyperlinkString = text.count - hyperlink.count
        attributed.addAttributes([.underlineStyle : NSUnderlineStyle.single.rawValue, .foregroundColor: UIColor.blueAccent, .font : UIFont.checkboxText], range: NSMakeRange(countMinusHyperlinkString, hyperlink.count))
                
        return attributed
    }
}

extension FormDataSource: CheckboxViewDelegate {
    func checkboxView(_ checkboxView: CheckboxView, didCompleteWithColumn column: String, value: String, fieldType: FormField.ColumnKind) {
        delegate?.checkboxView(checkboxView, didCompleteWithColumn: column, value: value, fieldType: fieldType)
        delegate?.formDataSource(self, checkboxUpdated: checkboxView)
    }
}

extension FormDataSource: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fields.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: FormCollectionViewCell = collectionView.dequeue(indexPath: indexPath)
        
        if let field = fields[safe: indexPath.item] { cell.configure(with: field) }
        
        return cell
    }
}
