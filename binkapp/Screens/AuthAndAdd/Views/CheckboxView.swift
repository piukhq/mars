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
    @IBOutlet private weak var textView: UITextView!

    private(set) var optional: Bool = false
    private(set) var columnName: String?
    private(set) var columnKind: FormField.ColumnKind?
    private(set) var textSelected: TextAction?
    private(set) var title: String? {
        didSet {
            textView.text = title
        }
    }
    
    private lazy var tapGesture = UITapGestureRecognizer(target: self, action: .textSelected)
    
    weak var delegate: CheckboxViewDelegate?
    
    func configure(title: String, columnName: String, columnKind: FormField.ColumnKind, url: URL? = nil, delegate: CheckboxViewDelegate? = nil, optional: Bool = false, textSelected: TextAction? = nil) {
        checkboxView.boxType = .square
        checkboxView.stateChangeAnimation = .flat(.fill)
        self.columnName = columnName
        self.columnKind = columnKind
        self.delegate = delegate
        self.optional = optional
        self.textSelected = textSelected
        
        checkboxView.addTarget(self, action: #selector(checkboxValueChanged(_:)), for: .valueChanged)

        if let safeUrl = url {
            let attributedString = NSMutableAttributedString(string: title)
            attributedString.addAttribute(.link, value: safeUrl, range: NSRange(location: title.count - columnName.count, length: columnName.count))
            textView.attributedText = attributedString
        } else {
            self.title = title
        }

        textView.font = UIFont.bodyTextSmall
        
        //We don't need a delegate if we don't have a checkbox, so we send a nil delegate to hide it
        checkboxView.isHidden = delegate == nil
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
    
    var value: String {
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
            checkboxView.setCheckState(.unchecked, animated: true)
            break
        case .unchecked:
            checkboxView.setCheckState(.checked, animated: true)
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
        
        guard let columnType = columnKind, let columnName = textView.text else { return }
        delegate?.checkboxView(self, didCompleteWithColumn: columnName, value: String(isChecked), fieldType: columnType)
    }
}

fileprivate extension Selector {
    static let textSelected = #selector(CheckboxView.textSelectedSelector)
}
