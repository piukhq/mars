//
//  FormField.swift
//  binkapp
//
//  Created by Max Woodhams on 14/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

enum FieldCommonName: String {
    case email
    case userName = "user_name"
    case password
    case placeOfBirth = "place_of_birth"
    case postcode
    case title
    case firstName = "first_name"
    case lastName = "last_name"
    case favoritePlace = "favorite_place"
    case gender
    case address1 = "address_1"
    case address2 = "address_2"
    case address3 = "address_3"
    case townCity = "town_city"
    case county
    case country
    case phoneNumber = "phone"
    case dateOfBirth = "date_of_birth"
    case memorableDate = "memorable_date"
    case barcode
    case cardNumber = "card_number"
}

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
        case email
        case sensitive
        case choice(data: [FormPickerData])
        case checkbox
        case paymentCardNumber
        case confirmPassword
        case expiry(months: [FormPickerData], years: [FormPickerData])
        case phone
        case date
        
        func keyboardType() -> UIKeyboardType {
            switch self {
            case .text, .sensitive, .confirmPassword:
                return .default
            case .paymentCardNumber:
                return .numberPad
            case .email:
                return .emailAddress
            case .phone:
                return .phonePad
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
        
        var isSecureTextEntry: Bool {
            switch self {
            case .sensitive, .confirmPassword:
                return true
            default:
                return false
            }
        }
        
        static func fieldInputType(for simpleFieldInputType: InputType?, commonName: FieldCommonName?, choices: [String]? = nil) -> FieldInputType {
            switch simpleFieldInputType {
            case .textfield:
                switch commonName {
                case .email:
                    return .email
                case .phoneNumber:
                    return .phone
                case .dateOfBirth, .memorableDate:
                    return .date
                default:
                    return .text
                }
            case .sensitive:
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

    enum ColumnKind {
        case none
        case add
        case auth
        case enrol
        case register
        case planDocument
        case userPreference
    }
    
    let title: String
    let placeholder: String
    let validation: String?
    let validationErrorMessage: String?
    let columnKind: ColumnKind?
    let fieldType: FieldInputType
    let valueUpdated: ValueUpdatedBlock
    let fieldExited: FieldExitedBlock
    let pickerOptionsUpdated: PickerUpdatedBlock?
    let shouldChange: TextFieldShouldChange
    let manualValidate: ManualValidateBlock?
    let forcedValue: String?
    let isReadOnly: Bool
    private(set) var value: String?
    
    typealias ValueUpdatedBlock = (FormField, String?) -> ()
    typealias PickerUpdatedBlock = (FormField, [Any]) -> ()
    typealias TextFieldShouldChange = (FormField, UITextField, NSRange, String?) -> (Bool)
    typealias FieldExitedBlock = (FormField) -> ()
    typealias ManualValidateBlock = (FormField) -> (Bool)
        
    init(title: String, placeholder: String, validation: String?, validationErrorMessage: String? = nil, fieldType: FieldInputType, value: String? = nil, updated: @escaping ValueUpdatedBlock, shouldChange: @escaping TextFieldShouldChange, fieldExited: @escaping FieldExitedBlock,  pickerSelected: PickerUpdatedBlock? = nil, columnKind: ColumnKind? = nil, manualValidate: ManualValidateBlock? = nil, forcedValue: String? = nil, isReadOnly: Bool = false) {
        self.title = title
        self.placeholder = placeholder
        self.validation = validation
        self.validationErrorMessage = validationErrorMessage
        self.fieldType = fieldType
        self.value = value
        self.valueUpdated = updated
        self.shouldChange = shouldChange
        self.fieldExited = fieldExited
        self.pickerOptionsUpdated = pickerSelected
        self.columnKind = columnKind
        self.manualValidate = manualValidate
        self.forcedValue = forcedValue
        self.value = forcedValue // Initialise the field's value with any forced value. If there isn't a forced value, the value will default to nil as normal.
        self.isReadOnly = isReadOnly
    }
    
    func isValid() -> Bool {
        // If our value is unset then  we do not pass the validation check
        guard let value = value else { return false }

        // If the field has manual validation, apply it
        if let validateBlock = manualValidate {
            return validateBlock(self)
        }
        
        if fieldType == .paymentCardNumber {
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
