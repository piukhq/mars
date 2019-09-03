//
//  LoginTextfieldView.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import UIKit

protocol LoginTextFieldDelegate {
    func loginTextFieldView(_ loginTextFieldView: LoginTextFieldView, didCompleteWithColumn column: String, value: String, fieldType: FieldType)
}

class LoginTextFieldView: CustomView {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var textField: UITextField!
    @IBOutlet private weak var separatorView: UIView!
    
    private var delegate: LoginTextFieldDelegate?
    private var validationRegEx: String?
    private var title: String = ""
    private var fieldType: FieldType?
    
    func configure(title: String, placeholder: String?, validationRegEx: String?, isPassword: Bool = false, fieldType: FieldType, delegate: LoginTextFieldDelegate) {
        titleLabel.text = title
        textField.placeholder = placeholder
        textField.isSecureTextEntry = isPassword

        self.title = title
        self.validationRegEx = validationRegEx
        self.fieldType = fieldType
        self.delegate = delegate
    }
    
    override func configureUI() {
        textField.delegate = self
        
        titleLabel.font = UIFont.textFieldLabel
        textField.font = UIFont.textFieldInput
    }
}

extension LoginTextFieldView: InputValidation {
    var isValid: Bool {
        guard let regEx = validationRegEx else { return true }
        let predicate = NSPredicate(format: "SELF MATCHES %@", regEx)
        if predicate.evaluate(with: textField.text) == true {
            if let fType = fieldType {
                delegate?.loginTextFieldView(self, didCompleteWithColumn: title, value: textField.text ?? "", fieldType: fType)
                return true
            }
        }
        return false
    }
    
}

extension LoginTextFieldView: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if isValid && fieldType != nil {
            guard let fType = fieldType else { return }
            delegate?.loginTextFieldView(self, didCompleteWithColumn: title, value: textField.text ?? "", fieldType: fType)
        } else {
            print("IT IS NOT VALID")
            titleLabel.textColor = .red
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        titleLabel.textColor = .black
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return false
    }
}
