//
//  FormCollectionViewCell.swift
//  binkapp
//
//  Created by Max Woodhams on 14/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class FormCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Helpers
    
    private struct Constants {
        static let titleLabelHeight: CGFloat = 20.0
        static let textFieldHeight: CGFloat = 24.0
        static let stackViewSpacing: CGFloat = 2.0
        static let postTextFieldSpacing: CGFloat = 16.0
        static let postSeparatorSpacing: CGFloat = 8.0
    }

    // MARK: - Properties
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.textFieldLabel
        label.heightAnchor.constraint(equalToConstant: Constants.titleLabelHeight).isActive = true
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()
    
    private lazy var textField: UITextField = {
        let field = UITextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.font = UIFont.textFieldInput
        field.delegate = self
        field.heightAnchor.constraint(equalToConstant: Constants.textFieldHeight).isActive = true
        field.addTarget(self, action: .textFieldUpdated, for: .editingChanged)
        field.setContentCompressionResistancePriority(.required, for: .vertical)
        field.inputAccessoryView = inputAccessory
        field.clearButtonMode = .whileEditing
        return field
    }()
    
    private lazy var inputAccessory: UIToolbar = {
        let bar = UIToolbar()
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: "Done", style: .plain, target: self, action: .accessoryDoneTouchUpInside)
        bar.items = [flexSpace, done]
        bar.sizeToFit()
        return bar
    }()
    
    private lazy var validationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = UIFont.textFieldExplainer
        label.textColor = .red
        label.text = "form_field_validation_error".localized
        label.isHidden = true
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()
    
    private lazy var fieldStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, textField, separator, validationLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.alignment = .fill
        stackView.spacing = Constants.stackViewSpacing
        stackView.setCustomSpacing(Constants.postTextFieldSpacing, after: textField)
        stackView.setCustomSpacing(Constants.postSeparatorSpacing, after: separator)
        contentView.addSubview(stackView)
        return stackView
    }()
    
    private lazy var separator: UIView = {
        let separator = UIView()
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.heightAnchor.constraint(equalToConstant: 1.0).isActive = true
        separator.backgroundColor = UIColor(hexString: "e5e5e5")
        contentView.addSubview(separator)
        return separator
    }()
    
    private var preferredWidth: CGFloat = 300 // This has to be a non zero value, chose 300 because of the movie 300.
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let layoutAttributes = super.preferredLayoutAttributesFitting(layoutAttributes)
        layoutAttributes.frame.size.width = preferredWidth
        return layoutAttributes
    }
    
    weak private var formField: FormField?
    
    // MARK: - Initialisation
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    
    private func configureLayout() {
        let topConstraint = fieldStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 17.0)
        topConstraint.priority = .almostRequired
        let bottomConstraint = contentView.bottomAnchor.constraint(equalTo: fieldStack.bottomAnchor)
        bottomConstraint.priority = .almostRequired
        
        NSLayoutConstraint.activate([
            fieldStack.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            fieldStack.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            topConstraint,
            bottomConstraint,
            separator.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            separator.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            ])
    }
    
    // MARK: - Public Methods
    
    func configure(with field: FormField) {
        titleLabel.text = field.title
        textField.placeholder = field.placeholder
        textField.isSecureTextEntry = field.fieldType.isSecureTextEntry()
        textField.keyboardType = field.fieldType.keyboardType()
        textField.autocorrectionType = field.fieldType.autoCorrection()
        textField.autocapitalizationType = field.fieldType.capitalization()
        formField = field
        
        if case let .expiry(months, years) = field.fieldType {
            textField.inputView = FormMultipleChoiceInput(with: [months, years], delegate: self)
        }  else if case let .choice(data) = field.fieldType {
            textField.inputView = FormMultipleChoiceInput(with: [data], delegate: self)
        } else {
            textField.inputView = nil
        }
    }
    
    func setWidth(_ width: CGFloat) {
        preferredWidth = width
    }
    
    // MARK: - Actions
    
    @objc func textFieldUpdated(_ textField: UITextField, text: String?, backingData: [Int]?) {
        formField?.updateValue(textField.text)
    }
    
    @objc func accessoryDoneTouchUpInside() {
        textField.resignFirstResponder()
    }
}

extension FormCollectionViewCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return formField?.textField(textField, shouldChangeInRange: range, newValue: string) ?? false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let field = formField else { return }
        validationLabel.text = field.validationErrorMessage != nil ? field.validationErrorMessage : "form_field_validation_error".localized
        validationLabel.isHidden = field.isValid()
        field.fieldWasExited()
    }
}

extension FormCollectionViewCell: FormMultipleChoiceInputDelegate {
    func multipleChoiceSeparatorForMultiValues() -> String? {
        return "/"
    }
    
    func multipleChoiceInputDidUpdate(newValue: String?, backingData: [Int]?) {
        formField?.updateValue(newValue)
        textField.text = newValue
        if let options = backingData { formField?.pickerDidSelect(options) }
    }
}

fileprivate extension Selector {
    static let textFieldUpdated = #selector(FormCollectionViewCell.textFieldUpdated(_:text:backingData:))
    static let accessoryDoneTouchUpInside = #selector(FormCollectionViewCell.accessoryDoneTouchUpInside)
}
