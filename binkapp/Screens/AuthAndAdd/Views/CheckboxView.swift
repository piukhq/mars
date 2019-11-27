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
    @IBOutlet private weak var textView: UITextView!
    
    private(set) var columnName: String?
    private(set) var columnKind: FormField.ColumnKind?
    private(set) var title: String? {
        didSet {
            textView.text = title
        }
    }
    weak var delegate: CheckboxViewDelegate?
    
    func configure(title: String, columnName: String, columnKind: FormField.ColumnKind, url: URL? = nil, delegate: CheckboxViewDelegate? = nil) {
        self.columnName = columnName
        self.columnKind = columnKind
        self.delegate = delegate
        
        checkboxView.addTarget(self, action: #selector(checkboxValueChanged(_:)), for: .valueChanged)

        if let safeUrl = url {
            let attributedString = NSMutableAttributedString(string: title)
            attributedString.addAttribute(.link, value: safeUrl, range: NSRange(location: title.count - columnName.count, length: columnName.count))
            textView.attributedText = attributedString
        } else {
            self.title = title
        }

        textView.font = UIFont.bodyTextSmall
    }
    
    override func configureUI() {
        textView.isUserInteractionEnabled = true
        textView.delegate = self
        textView.linkTextAttributes = [.foregroundColor: UIColor.blueAccent, .underlineStyle: NSUnderlineStyle.single.rawValue]
        checkboxView.boxType = .square
        checkboxView.stateChangeAnimation = .flat(.fill)
    }
}

extension CheckboxView: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return true
    }
}

extension CheckboxView: InputValidation {
    var isValid: Bool {
        return checkboxView.checkState == .checked
    }
    
    @objc func checkboxValueChanged(_ sender: Any) {
        let isChecked = checkboxView.checkState == .checked
        
        guard let columnType = columnKind, let columnName = title else { return }
        delegate?.checkboxView(self, didCompleteWithColumn: columnName, value: String(isChecked), fieldType: columnType)
    }
}
