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
    }
    
    let title: String
    let placeholder: String
    let validation: String
    let fieldType: FieldInputType
    let valueUpdated: ValueUpdatedBlock
    let shouldChange: TextFieldShouldChange
    private(set) var value: String?
    
    typealias ValueUpdatedBlock = (FormField, String?) -> ()
    typealias TextFieldShouldChange = (FormField, UITextField, NSRange, String?) -> (Bool)
        
    init(title: String, placeholder: String, validation: String, fieldType: FieldInputType, value: String? = nil, updated: @escaping ValueUpdatedBlock, shouldChange: @escaping TextFieldShouldChange) {
        self.title = title
        self.placeholder = placeholder
        self.validation = validation
        self.fieldType = fieldType
        self.value = value
        self.valueUpdated = updated
        self.shouldChange = shouldChange
    }
    
    func validate() -> Bool {
        // If our value is unset then  we do not pass the validation check
        guard let value = value else { return false }
        
        if fieldType == .cardNumber {
            return PaymentCardType.validate(fullPan: value)
        } else {
            let predicate = NSPredicate(format: "SELF MATCHES %@", validation)
            return predicate.evaluate(with: value)
        }
    }
    
    func updateValue(_ value: String?) {
        self.value = value
        valueUpdated(self, value)
    }
    
    func textField(_ textField: UITextField, shouldChangeInRange: NSRange, newValue: String?) -> Bool {
        return shouldChange(self, textField, shouldChangeInRange, newValue)
    }
}
