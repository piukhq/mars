//
//  FormField.swift
//  binkapp
//
//  Created by Max Woodhams on 14/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

struct FormPickerData: Equatable {
    
    let title: String
    let backingData: Int?
    
    init?(_ title: String?, backingData: Int? = nil) {
        guard let title = title else { return nil }
        
        self.title = title
        self.backingData = backingData
    }
}

class FormField {
    enum FieldInputType: Equatable {
        case text
        case sensitive
        case choice(data: [FormPickerData])
        case checkbox
        case cardNumber
        case expiry(months: [FormPickerData], years: [FormPickerData])
        
        func keyboardType() -> UIKeyboardType {
            switch self {
            case .cardNumber:
                return .numberPad
            case .text, .sensitive:
                return .alphabet
            default:
                return .default
            }
        }
        
        func capitalization() -> UITextAutocapitalizationType {
            switch self {
            case .text:
                return .words
            default:
                return .none
            }
        }
        
        func autoCorrection() -> UITextAutocorrectionType {
            return .no
        }
        
        static func fieldInputType(for simpleFieldInputType: InputType?, choices: [String]? = nil) -> FieldInputType {
            switch simpleFieldInputType {
            case .textfield:
                return .text
            case .password:
                return .sensitive
            case .checkbox:
                return .checkbox
            case .dropdown:
                if let choices = choices {
                    let data = choices.compactMap { FormPickerData($0) }
                    return .choice(data: data)
                } else {
                    return .choice(data: [])
                }
            case .none:
                return .text
            }
        }
    }
    
    enum ColumnKind: String {
        case add
        case auth
        case enrol
        case register
    }
    
    let title: String
    let placeholder: String
    let validation: String?
    let columnKind: ColumnKind?
    let fieldType: FieldInputType
    let valueUpdated: ValueUpdatedBlock
    let fieldExited: FieldExitedBlock
    let pickerOptionsUpdated: PickerUpdatedBlock?
    let shouldChange: TextFieldShouldChange
    private(set) var value: String?
    
    typealias ValueUpdatedBlock = (FormField, String?) -> ()
    typealias PickerUpdatedBlock = (FormField, [Any]) -> ()
    typealias TextFieldShouldChange = (FormField, UITextField, NSRange, String?) -> (Bool)
    typealias FieldExitedBlock = (FormField) -> ()
        
    init(title: String, placeholder: String, validation: String?, fieldType: FieldInputType, value: String? = nil, updated: @escaping ValueUpdatedBlock, shouldChange: @escaping TextFieldShouldChange, fieldExited: @escaping FieldExitedBlock,  pickerSelected: PickerUpdatedBlock? = nil, columnKind: ColumnKind? = nil) {
        self.title = title
        self.placeholder = placeholder
        self.validation = validation
        self.fieldType = fieldType
        self.value = value
        self.valueUpdated = updated
        self.shouldChange = shouldChange
        self.fieldExited = fieldExited
        self.pickerOptionsUpdated = pickerSelected
        self.columnKind = columnKind
    }
    
    func isValid() -> Bool {
        // If our value is unset then  we do not pass the validation check
        guard let value = value else { return false }
        
        if fieldType == .cardNumber {
            return PaymentCardType.validate(fullPan: value)
        } else {
            guard let validation = validation else { return !value.isEmpty }
            
            let predicate = NSPredicate(format: "SELF MATCHES %@", validation)
            return predicate.evaluate(with: value)
        }
    }
    
    func updateValue(_ value: String?) {
        self.value = value
        valueUpdated(self, value)
    }
    
    func pickerDidSelect(_ options: [Any]) {
        pickerOptionsUpdated?(self, options)
    }
    
    func fieldWasExited() {
        fieldExited(self)
    }
    
    func textField(_ textField: UITextField, shouldChangeInRange: NSRange, newValue: String?) -> Bool {
        return shouldChange(self, textField, shouldChangeInRange, newValue)
    }
}
