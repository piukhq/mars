//
//  CheckboxView.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit
import M13Checkbox

class CheckboxView: CustomView {
    @IBOutlet private weak var checkboxView: M13Checkbox!
    @IBOutlet private weak var titleLabel: UILabel!
    
    private var fieldType: FieldType?
    
    func configure(title: String, fieldType: FieldType) {
        titleLabel.text = title
        checkboxView.boxType = .square
        checkboxView.stateChangeAnimation = .flat(.fill)
        
        self.fieldType = fieldType
        titleLabel.font = UIFont.bodyTextSmall
    }
}

extension CheckboxView: InputValidation {
    var isValid: Bool {
        return checkboxView.checkState == .checked
    }
}
