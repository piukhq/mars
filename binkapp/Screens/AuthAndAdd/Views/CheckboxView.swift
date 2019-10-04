//
//  CheckboxView.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit
import M13Checkbox

protocol CheckboxViewDelegate: class {
    func checkboxView(_ checkboxView: CheckboxView, didCompleteWithColumn column: String, value: String, fieldType: FieldType)
}

class CheckboxView: CustomView {
    @IBOutlet private weak var checkboxView: M13Checkbox!
    @IBOutlet private weak var titleLabel: UILabel!
    
    private weak var delegate: CheckboxViewDelegate?
    private var fieldType: FieldType?
    private var columnName: String = ""
    
    func configure(title: String, columnName: String, fieldType: FieldType, delegate: CheckboxViewDelegate) {
        self.delegate = delegate
        self.columnName = columnName
        titleLabel.text = title
        checkboxView.boxType = .square
        checkboxView.stateChangeAnimation = .flat(.fill)
        
        self.fieldType = fieldType
        titleLabel.font = UIFont.bodyTextSmall
    }
}

extension CheckboxView: InputValidation {
    var isValid: Bool {
        if let fType = fieldType {
            let isChecked = checkboxView.checkState == .checked ? true : false
            delegate?.checkboxView(self, didCompleteWithColumn: columnName, value: String(isChecked), fieldType: fType)
        }
        return true
    }
}
