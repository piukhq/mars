//
//  FormCollectionViewCell.swift
//  binkapp
//
//  Created by Max Woodhams on 14/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class FormCollectionViewCell: UICollectionViewCell, ReusableView {

    // MARK: - Properties
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.textFieldLabel
        return label
    }()
    
    lazy var textField: UITextField = {
        let field = UITextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.font = UIFont.textFieldInput
        field.delegate = self
        field.addTarget(self, action: .textFieldUpdated, for: .editingChanged)
        return field
    }()
    
    lazy var fieldStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, textField])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.alignment = .fill
        stackView.spacing = 2.0
        contentView.addSubview(stackView)
        return stackView
    }()
    
    weak private var formField: FormField?
    
    // MARK: - Initialisation
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureLayout() {
        NSLayoutConstraint.activate([
            fieldStack.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            fieldStack.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            fieldStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            ])
    }
    
    // MARK: - Public Method
    
    func configure(with field: FormField) {
        titleLabel.text = field.title
        textField.placeholder = field.placeholder
        textField.isSecureTextEntry = field.fieldType == .sensitive
        textField.keyboardType = field.fieldType.keyboardType()
        textField.autocorrectionType = field.fieldType.autoCorrection()
        textField.autocapitalizationType = field.fieldType.capitalization()
        formField = field
        
        if case let .expiry(months, years) = field.fieldType {
            textField.inputView = FormMultipleChoiceInput(with: [months, years], delegate: self)
        }
    }
}

extension FormCollectionViewCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return formField?.textField(textField, shouldChangeInRange: range, newValue: string) ?? false
    }
    
    @objc func textFieldUpdated(_ textField: UITextField, text: String?, backingData: [Int]?) {
        formField?.updateValue(textField.text)
    }
}

extension FormCollectionViewCell: FormMultipleChoiceInputDelegate {
    func multipleChoiceSeparatorForMultiValues() -> String? {
        return "/"
    }
    
    func multipleChoiceInputDidUpdate(newValue: String?, backingData: [Int]?) {
        textField.text = newValue
        if let options = backingData { formField?.pickerDidSelect(options) }
    }
}

fileprivate extension Selector {
    static let textFieldUpdated = #selector(FormCollectionViewCell.textFieldUpdated(_:text:backingData:))
}
