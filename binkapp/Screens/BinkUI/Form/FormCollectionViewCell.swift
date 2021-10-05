//
//  FormCollectionViewCell.swift
//  binkapp
//
//  Created by Max Woodhams on 14/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

protocol FormCollectionViewCellDelegate: AnyObject {
    func formCollectionViewCell(_ cell: FormCollectionViewCell, didSelectField: UITextField)
    func formCollectionViewCell(_ cell: FormCollectionViewCell, shouldResignTextField textField: UITextField)
    func formCollectionViewCellDidReceiveLoyaltyScannerButtonTap(_ cell: FormCollectionViewCell)
    func formCollectionViewCellDidReceivePaymentScannerButtonTap(_ cell: FormCollectionViewCell)
}

extension FormCollectionViewCellDelegate {
    func formCollectionViewCellDidReceiveLoyaltyScannerButtonTap(_ cell: FormCollectionViewCell) {}
    func formCollectionViewCellDidReceivePaymentScannerButtonTap(_ cell: FormCollectionViewCell) {}
}

class FormCollectionViewCell: UICollectionViewCell {
    private weak var delegate: FormCollectionViewCellDelegate?
    // MARK: - Helpers
    
    private enum Constants {
        static let titleLabelHeight: CGFloat = 20.0
        static let textFieldHeight: CGFloat = 24.0
        static let stackViewSpacing: CGFloat = 2.0
        static let postTextFieldSpacing: CGFloat = 16.0
        static let postSeparatorSpacing: CGFloat = 8.0
        static let validationLabelHeight: CGFloat = 20.0
    }

    // MARK: - Properties
    
    private lazy var textFieldStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [textField, textFieldRightView])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        stackView.alignment = .fill
        contentView.addSubview(stackView)
        return stackView
    }()
    
    lazy var textFieldRightView: UIView = {
        let cameraButton = UIButton(type: .custom)
        cameraButton.imageEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        cameraButton.setImage(Asset.scanIcon.image, for: .normal)
        cameraButton.imageView?.contentMode = .scaleAspectFill
        cameraButton.addTarget(self, action: .handleScanButtonTap, for: .touchUpInside)
        cameraButton.translatesAutoresizingMaskIntoConstraints = false
        cameraButton.setContentHuggingPriority(.required, for: .horizontal)
        return cameraButton
    }()
    
    lazy var textField: UITextField = {
        let field = UITextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.font = UIFont.textFieldInput
        field.delegate = self
        field.heightAnchor.constraint(equalToConstant: Constants.textFieldHeight).isActive = true
        field.addTarget(self, action: .textFieldUpdated, for: .editingChanged)
        field.setContentCompressionResistancePriority(.required, for: .vertical)
        field.inputAccessoryView = inputAccessory
        field.smartQuotesType = .no // This stops the "smart" apostrophe setting. The default breaks field regex validation
        return field
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.textFieldLabel
        label.heightAnchor.constraint(equalToConstant: Constants.titleLabelHeight).isActive = true
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()
    
    private lazy var inputAccessory: UIToolbar = {
        let bar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
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
        label.text = L10n.formFieldValidationError
        label.isHidden = true
        label.textColor = .binkDynamicRed
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.widthAnchor.constraint(equalToConstant: preferredWidth).isActive = true
        return label
    }()
    
    private lazy var fieldStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, textFieldStack, separator, validationLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = Constants.stackViewSpacing
        stackView.setCustomSpacing(Constants.postTextFieldSpacing, after: textFieldStack)
        stackView.setCustomSpacing(Constants.postSeparatorSpacing, after: separator)
        contentView.addSubview(stackView)
        return stackView
    }()
    
    private lazy var separator: UIView = {
        let separator = UIView()
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.heightAnchor.constraint(equalToConstant: 1.0).isActive = true
        contentView.addSubview(separator)
        return separator
    }()
    
    private var preferredWidth: CGFloat = 300 // This has to be a non zero value, chose 300 because of the movie 300.
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let layoutAttributes = super.preferredLayoutAttributesFitting(layoutAttributes)
        layoutAttributes.frame.size.width = preferredWidth
        layoutAttributes.bounds.size.height = contentView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height

        return layoutAttributes
    }
    
    private weak var formField: FormField?
    private var pickerSelectedChoice: String?
    var isValidationLabelHidden = true
    
    // MARK: - Initialisation
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureLayout()
        Current.themeManager.addObserver(self, handler: #selector(configureForCurrentTheme))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Layout
    
    private func configureLayout() {
        let topConstraint = fieldStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 17.0)
        topConstraint.priority = .required
        let bottomConstraint = contentView.bottomAnchor.constraint(equalTo: fieldStack.bottomAnchor)
        bottomConstraint.priority = .required
        
        NSLayoutConstraint.activate([
            fieldStack.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            fieldStack.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            topConstraint,
            bottomConstraint,
            separator.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            separator.rightAnchor.constraint(equalTo: contentView.rightAnchor)
        ])
    }
    
    // MARK: - Public Methods

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        configureForCurrentTheme()
    }

    @objc private func configureForCurrentTheme() {
        validationLabel.textColor = .binkDynamicRed
    }

    func configure(with field: FormField, delegate: FormCollectionViewCellDelegate?) {
        let isEnabled = !field.isReadOnly
        
        tintColor = Current.themeManager.color(for: .text)
        titleLabel.text = field.title
        titleLabel.textColor = isEnabled ? Current.themeManager.color(for: .text) : .binkDynamicGray
        textField.textColor = isEnabled ? Current.themeManager.color(for: .text) : .binkDynamicGray
        textField.text = field.forcedValue
        textField.placeholder = field.placeholder
        textField.isSecureTextEntry = field.fieldType.isSecureTextEntry
        textField.keyboardType = field.fieldType.keyboardType()
//        textField.autocorrectionType = field.fieldType.autoCorrection()
        textField.autocapitalizationType = field.fieldType.capitalization()
        textField.clearButtonMode = field.fieldCommonName == .barcode ? .always : .whileEditing
        textField.accessibilityIdentifier = field.title
        formField = field
        configureTextFieldRightView(shouldDisplay: formField?.value == nil)
        validationLabel.isHidden = textField.text?.isEmpty == true ? true : field.isValid()
        separator.backgroundColor = Current.themeManager.color(for: .divider)
        
        if case let .expiry(months, years) = field.fieldType {
            textField.inputView = FormMultipleChoiceInput(with: [months, years], delegate: self)
        } else if case let .choice(data) = field.fieldType {
            textField.inputView = FormMultipleChoiceInput(with: [data], delegate: self)
            pickerSelectedChoice = data.first?.title
            formField?.updateValue(pickerSelectedChoice)
        } else if case .date = field.fieldType {
            let datePicker = UIDatePicker()
            datePicker.datePickerMode = .date
            datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)

            if #available(iOS 14.0, *) {
                datePicker.preferredDatePickerStyle = .inline
                datePicker.backgroundColor = Current.themeManager.color(for: .viewBackground)
                datePicker.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 400)
            }

            textField.inputView = datePicker
            pickerSelectedChoice = datePicker.date.getFormattedString(format: .dayShortMonthYearWithSlash)
            formField?.updateValue(pickerSelectedChoice)
        } else {
            textField.inputView = nil
        }
        
        self.delegate = delegate
    }
    
    func setWidth(_ width: CGFloat) {
        preferredWidth = width
    }
    
    // MARK: - Actions
    
    @objc func textFieldUpdated(_ textField: UITextField, text: String?, backingData: [Int]?) {
        guard let textFieldText = textField.text else { return }
        formField?.updateValue(textFieldText)
        configureTextFieldRightView(shouldDisplay: textFieldText.isEmpty)
    }
    
    private func configureTextFieldRightView(shouldDisplay: Bool) {
        if formField?.fieldCommonName == .cardNumber && formField?.alternatives?.contains(.barcode) == true && shouldDisplay {
            textFieldRightView.isHidden = false
        } else if formField?.fieldCommonName == .cardNumber && shouldDisplay {
            textFieldRightView.isHidden = false
        } else {
            textFieldRightView.isHidden = true
        }
    }
    
    @objc func accessoryDoneTouchUpInside() {
        if let multipleChoiceInput = textField.inputView as? FormMultipleChoiceInput {
            multipleChoiceInputDidUpdate(newValue: multipleChoiceInput.fullContentString, backingData: multipleChoiceInput.backingData)
        }
        
        textField.resignFirstResponder()
        textFieldDidEndEditing(textField)
    }
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        let selectedDate = sender.date.getFormattedString(format: .dayShortMonthYearWithSlash)
        pickerSelectedChoice = selectedDate
        formField?.updateValue(pickerSelectedChoice)
        textField.text = selectedDate
    }
    
    @objc func handleScanButtonTap() {
        if formField?.fieldType == .paymentCardNumber {
            delegate?.formCollectionViewCellDidReceivePaymentScannerButtonTap(self)
        } else {
            delegate?.formCollectionViewCellDidReceiveLoyaltyScannerButtonTap(self)
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        // In order to allow a field to appear disabled, but allow the clear button to still be functional, we cannot make the textfield disabled
        // So we must block the editing instead, which allows the clear button to still work
        return formField?.isReadOnly == false
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        if formField?.fieldCommonName == .barcode {
//            formField?.dataSourceRefreshBlock?()
            return false
        }
        configureTextFieldRightView(shouldDisplay: true)
        return true
    }
}

extension FormCollectionViewCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return formField?.textField(textField, shouldChangeInRange: range, newValue: string) ?? false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let field = formField else { return }
        validationLabel.text = field.validationErrorMessage != nil ? field.validationErrorMessage : L10n.formFieldValidationError
        validationLabel.isHidden = field.isValid()
        isValidationLabelHidden = field.isValid()
        field.fieldWasExited()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.inputView?.isKind(of: FormMultipleChoiceInput.self) ?? false || textField.inputView?.isKind(of: UIDatePicker.self) ?? false {
            textField.text = pickerSelectedChoice
        }
        
        self.delegate?.formCollectionViewCell(self, didSelectField: textField)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.delegate?.formCollectionViewCell(self, shouldResignTextField: textField)
        return true
    }
}

extension FormCollectionViewCell: FormMultipleChoiceInputDelegate {
    func multipleChoiceSeparatorForMultiValues() -> String? {
        return "/"
    }
    
    func multipleChoiceInputDidUpdate(newValue: String?, backingData: [Int]?) {
        pickerSelectedChoice = newValue
        formField?.updateValue(newValue)
        textField.text = newValue
        if let options = backingData { formField?.pickerDidSelect(options) }
    }
}

fileprivate extension Selector {
    static let textFieldUpdated = #selector(FormCollectionViewCell.textFieldUpdated(_:text:backingData:))
    static let accessoryDoneTouchUpInside = #selector(FormCollectionViewCell.accessoryDoneTouchUpInside)
    static let handleScanButtonTap = #selector(FormCollectionViewCell.handleScanButtonTap)
}
