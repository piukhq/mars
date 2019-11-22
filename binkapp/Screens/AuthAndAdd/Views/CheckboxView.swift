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
    typealias TextAction = () -> ()
    @IBOutlet private weak var checkboxView: M13Checkbox!
    @IBOutlet private weak var titleLabel: UILabel!
 
    private(set) var optional: Bool = false
    private(set) var columnName: String?
    private(set) var columnKind: FormField.ColumnKind?
    private(set) var textSelected: TextAction?
    private(set) var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    private lazy var tapGesture = UITapGestureRecognizer(target: self, action: .textSelected)
    
    weak var delegate: CheckboxViewDelegate?
    
    func configure(title: String? = nil, attributedTitle: NSAttributedString? = nil, columnName: String, columnKind: FormField.ColumnKind, delegate: CheckboxViewDelegate? = nil, optional: Bool = false, textSelected: TextAction? = nil) {
        checkboxView.boxType = .square
        checkboxView.stateChangeAnimation = .flat(.fill)
        self.columnName = columnName
        self.title = title != nil ? title : attributedTitle?.string
        self.columnKind = columnKind
        self.delegate = delegate
        self.optional = optional
        self.textSelected = textSelected
        
        titleLabel.font = UIFont.bodyTextSmall
        titleLabel.addGestureRecognizer(tapGesture)
        checkboxView.addTarget(self, action: #selector(checkboxValueChanged(_:)), for: .valueChanged)
    }
    
    func getValue() -> String {
        return checkboxView.checkState == .checked ? "1" : "0"
    }
    
    func setValue(newValue: String) {
        switch newValue {
        case "0":
            checkboxView.checkState = .unchecked
            break
        case "1":
            checkboxView.checkState = .checked
            break
        default:
            checkboxView.checkState = .unchecked
            break
        }
    }
    
    @objc func textSelectedSelector() {
        textSelected?()
    }
    
    func toggleState() {
        switch checkboxView.checkState {
        case .checked:
            checkboxView.checkState = .unchecked
            break
        case .unchecked:
            checkboxView.checkState = .checked
            break
        case .mixed:
            break
        }
    }
}

extension CheckboxView: InputValidation {
    var isValid: Bool {
        return optional ? true : checkboxView.checkState == .checked
    }
    
    @objc func checkboxValueChanged(_ sender: Any) {
        let isChecked = checkboxView.checkState == .checked
        
        guard let columnType = columnKind, let columnName = title else { return }
        delegate?.checkboxView(self, didCompleteWithColumn: columnName, value: String(isChecked), fieldType: columnType)
    }
}

fileprivate extension Selector {
    static let textSelected = #selector(CheckboxView.textSelectedSelector)
}
