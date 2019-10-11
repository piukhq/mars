//
//  CheckboxView.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit
import M13Checkbox

protocol CheckboxViewDelegate: NSObjectProtocol {
    func checkboxView(_ checkboxView: CheckboxView, didCompleteWithColumn column: String, value: String, fieldType: FormField.ColumnKind)
}

class CheckboxView: CustomView {
    @IBOutlet private weak var checkboxView: M13Checkbox!
    @IBOutlet private weak var titleLabel: UILabel!
 
    private var columnName: String = ""
    private(set) var columnKind: FormField.ColumnKind?
    private(set) var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    weak var delegate: CheckboxViewDelegate?
    
    func configure(title: String, columnName: String, columnKind: FormField.ColumnKind, delegate: CheckboxViewDelegate? = nil) {
        checkboxView.boxType = .square
        checkboxView.stateChangeAnimation = .flat(.fill)
        self.title = title
        self.columnKind = columnKind
        self.delegate = delegate
        
        titleLabel.font = UIFont.bodyTextSmall
        checkboxView.addTarget(self, action: #selector(checkboxValueChanged(_:)), for: .valueChanged)
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
    
    @objc func checkboxValueChanged(_ sender: Any) {
        let isChecked = checkboxView.checkState == .checked ? true : false
        delegate?.checkboxView(self, didCompleteWithColumn: columnName, value: String(isChecked), fieldType: columnKind)
    }
}
