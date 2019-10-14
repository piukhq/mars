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
}

extension FormDataSourceDelegate {
    func formDataSource(_ dataSource: FormDataSource, changed value: String?, for field: FormField) {}
    func formDataSource(_ dataSource: FormDataSource, selected options: [Any], for field: FormField) {}
    func formDataSource(_ dataSource: FormDataSource, fieldDidExit: FormField) {}
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
        let checkboxesValid = checkboxes.reduce(true, { $0 && $1.isValid })
        
        return formFieldsValid && checkboxesValid
    }
    
    func currentFieldValues() -> [String: String] {
        var values = [String: String]()
        fields.forEach { values[$0.title] = $0.value }
        
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
            fieldType: .expiry(months: monthData, years: yearData),
            updated: updatedBlock,
            shouldChange: shouldChangeBlock,
            fieldExited: fieldExitedBlock,
            pickerSelected: pickerUpdatedBlock
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
        
        if formPurpose == .firstLogin {
            model.account?.formattedAddFields?.sorted(by: { $0.order.intValue < $1.order.intValue }).forEach { field in
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
                            fieldType: FormField.FieldInputType.fieldInputType(for: field.fieldInputType, choices: field.choicesArray),
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
        
        if formPurpose != .signUp {
            model.account?.formattedAuthFields?.sorted(by: { $0.order.intValue < $1.order.intValue }).forEach { field in
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
                            fieldType: FormField.FieldInputType.fieldInputType(for: field.fieldInputType, choices: field.choicesArray),
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
                            fieldType: FormField.FieldInputType.fieldInputType(for: field.fieldInputType, choices: field.choicesArray),
                            updated: updatedBlock,
                            shouldChange: shouldChangeBlock,
                            fieldExited: fieldExitedBlock,
                            columnKind: .enrol
                        )
                    )
                }
            }
        }
    }
}

extension FormDataSource: CheckboxViewDelegate {
    func checkboxView(_ checkboxView: CheckboxView, didCompleteWithColumn column: String, value: String, fieldType: FormField.ColumnKind) {
        delegate?.checkboxView(checkboxView, didCompleteWithColumn: column, value: value, fieldType: fieldType)
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
