//
//  DropdownView.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit
import iOSDropDown

protocol DropdownDelegate {
    func dropdownView(_ dropdownView: DropdownView, didSetDataWithColumn column: String, value: String, fieldType: FieldType)
}

class DropdownView: CustomView {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var dropDownTextField: DropDown!
    @IBOutlet private weak var separatorView: UIView!
    
    private var delegate: DropdownDelegate?
    private var selectedOption: String? = nil
    private var title = ""
    private var fieldType: FieldType?
    
    func configure(title: String, choices: [String], fieldType: FieldType, delegate: DropdownDelegate) {
        titleLabel.text = title
        dropDownTextField.optionArray = choices

        self.title = title
        self.fieldType = fieldType
        self.delegate = delegate
    }
    
    override func configureUI() {
        dropDownTextField.isSearchEnable = false
        titleLabel.font = UIFont.textFieldLabel
        dropDownTextField.selectedRowColor = .lightGray
        
        dropDownTextField.didSelect { (text, _, _) in
            self.selectedOption = text
            if self.fieldType != nil {
                guard let fType = self.fieldType else { return }
                self.delegate?.dropdownView(self, didSetDataWithColumn: self.title, value: text, fieldType: fType)
            }
        }
    }
}

extension DropdownView: InputValidation {
    var isValid: Bool {
        return selectedOption != nil
    }
}
