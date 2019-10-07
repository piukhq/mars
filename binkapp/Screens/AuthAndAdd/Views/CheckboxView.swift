//
//  CheckboxView.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit
import M13Checkbox

protocol CheckboxViewDelegate: NSObjectProtocol {
    func checkboxStateDidChange()
}

class CheckboxView: CustomView {
    @IBOutlet private weak var checkboxView: M13Checkbox!
    @IBOutlet private weak var titleLabel: UILabel!
    
    private(set) var columnKind: FormField.ColumnKind?
    private(set) var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    weak var delegate: CheckboxViewDelegate?
    
    func configure(title: String, columnKind: FormField.ColumnKind, delegate: CheckboxViewDelegate? = nil) {
        checkboxView.boxType = .square
        checkboxView.stateChangeAnimation = .flat(.fill)
        self.title = title
        self.columnKind = columnKind
        self.delegate = delegate
        
        titleLabel.font = UIFont.bodyTextSmall
        checkboxView.addTarget(self, action: #selector(checkboxValueChanged(_:)), for: .valueChanged)
    }

    func isValid() -> Bool {
        return checkboxView.checkState == .checked
    }
    
    @objc func checkboxValueChanged(_ sender: Any) {
        delegate?.checkboxStateDidChange()
    }
}
