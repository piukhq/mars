//
//  AutofillFormInputAccessory.swift
//  binkapp
//
//  Created by Nick Farrant on 14/05/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import UIKit

protocol AutofillFormInputAccessoryDelegate: AnyObject {
    func inputAccessory(_ inputAccessory: AutofillFormInputAccessory, didSelectValue value: String)
    func inputAccessoryDidTapDone(_ inputAccessory: AutofillFormInputAccessory)
}

class AutofillFormInputAccessory: UIToolbar {
    private let field: FormField
    private weak var autofillDelegate: AutofillFormInputAccessoryDelegate?
    
    init(field: FormField, delegate: AutofillFormInputAccessoryDelegate) {
        self.field = field
        self.autofillDelegate = delegate
        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 100))
        sizeToFit()
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var collectionViewLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.estimatedItemSize = CGSize(width: 1, height: 1)
        return layout
    }()
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        return collectionView
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(handleDoneButtonTap), for: .touchUpInside)
        button.setTitle("Done", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var stackview: UIStackView = {
        let stackview = UIStackView(arrangedSubviews: [collectionView, doneButton])
        stackview.translatesAutoresizingMaskIntoConstraints = false
        stackview.axis = .horizontal
        stackview.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15)
        stackview.isLayoutMarginsRelativeArrangement = true
        addSubview(stackview)
        return stackview
    }()
    
    var autofillValues: [String]? {
        let autofillValues = Current.userDefaults.value(forDefaultsKey: .autofillFormValues) as? [String: [String]]
        return autofillValues?[field.title.lowercased()]?.sorted()
    }
    
    private func configure() {
        collectionView.register(AutofillFormInputCell.self, asNib: false)
        stackview.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        stackview.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
    }
    
    @objc func handleDoneButtonTap() {
        autofillDelegate?.inputAccessoryDidTapDone(self)
    }
}


// MARK: - CollectionView delegates

extension AutofillFormInputAccessory: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return autofillValues?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: AutofillFormInputCell = collectionView.dequeue(indexPath: indexPath)
        guard let value = autofillValues?[indexPath.row] else { return cell }
        cell.configureWithValue(value)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let value = autofillValues?[indexPath.row] {
            autofillDelegate?.inputAccessory(self, didSelectValue: value)
        }
    }
}


class PrefillFormValuesViewController: BaseFormViewController {
    init() {
        let dataSource = FormDataSource()
        super.init(title: "Prefill Form Values", description: "Enter values here to be prefilled into future forms.", dataSource: dataSource)
        self.dataSource.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var saveButton: BinkButton = {
        return BinkButton(type: .gradient, title: "Save", enabled: false) { [weak self] in
            self?.saveButtonTapped()
        }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        footerButtons.append(saveButton)
        saveButton.enabled = true
        
        getAllFields { fields in
            self.dataSource.setupPrefillValueFields(fields)
            self.collectionView.reloadData()
        }
    }
    
    @objc func saveButtonTapped() {
        let persistedPrefillValues = Current.userDefaults.value(forDefaultsKey: .autofillFormValues) as? [String: [String]]
        var newPrefillValues: [String: [String]] = persistedPrefillValues ?? [:]
        let fieldValues = dataSource.currentFieldValues()
        
        for key in fieldValues.keys {
            /// If the key already exists in the prefilled values, append the new value if unique
            if var object = newPrefillValues[key] {
                if let value = fieldValues[key], !object.contains(value) {
                    object.append(value)
                    newPrefillValues[key] = object
                }
            } else {
                /// If the key doesn't exist, add it
                if let value = fieldValues[key] {
                    newPrefillValues[key] = [value]
                }
            }
        }
        
        print("PREFILL: \(newPrefillValues)")
        Current.userDefaults.set(newPrefillValues, forDefaultsKey: .autofillFormValues)
        Current.navigate.close()
    }
}

extension PrefillFormValuesViewController: FormDataSourceDelegate {
    func formDataSource(_ dataSource: FormDataSource, textField: UITextField, shouldChangeTo newValue: String?, in range: NSRange, for field: FormField) -> Bool {
        return true
    }
    
    func formDataSource(_ dataSource: FormDataSource, manualValidate field: FormField) -> Bool {
        return true
    }
}

extension PrefillFormValuesViewController: FormCollectionViewCellDelegate {
    func formCollectionViewCell(_ cell: FormCollectionViewCell, didSelectField: UITextField) {}
    func formCollectionViewCell(_ cell: FormCollectionViewCell, shouldResignTextField textField: UITextField) {}
}

extension FormDataSource {
    func setupPrefillValueFields(_ enrolFields: [CD_EnrolField]) {
        let updatedBlock: FormField.ValueUpdatedBlock = { [weak self] field, newValue in
            guard let self = self else { return }
            self.delegate?.formDataSource(self, changed: newValue, for: field)
        }
        
        let shouldChangeBlock: FormField.TextFieldShouldChange = { [weak self] (field, textField, range, newValue) in
            guard let self = self, let delegate = self.delegate else { return true }
            return delegate.formDataSource(self, textField: textField, shouldChangeTo: newValue, in: range, for: field)
        }
        
        let fieldExitedBlock: FormField.FieldExitedBlock = { [weak self] field in
            guard let self = self else { return }
            self.delegate?.formDataSource(self, fieldDidExit: field)
        }
        
        let manualValidateBlock: FormField.ManualValidateBlock = { [weak self] field in
            guard let self = self, let delegate = self.delegate else { return false }
            return delegate.formDataSource(self, manualValidate: field)
        }
        
        let prefilledValues = Current.userDefaults.value(forDefaultsKey: .autofillFormValues) as? [String: [String]]
        
        enrolFields.forEach { field in
            var forcedValue: String? = ""
            if let column = field.column?.lowercased() {
                forcedValue = prefilledValues?[column]?.sorted().first
            }
                
            fields.append(
                FormField(
                    title: field.column ?? "",
                    placeholder: field.fieldDescription ?? "",
                    validation: field.validation,
                    fieldType: FormField.FieldInputType.fieldInputType(for: field.fieldInputType, commonName: field.fieldCommonName, choices: field.choicesArray),
                    updated: updatedBlock,
                    shouldChange: shouldChangeBlock,
                    fieldExited: fieldExitedBlock,
                    columnKind: .enrol,
                    manualValidate: manualValidateBlock,
                    forcedValue: forcedValue,
                    fieldCommonName: field.fieldCommonName
                )
            )
        }
    }
}

extension PrefillFormValuesViewController: CoreDataRepositoryProtocol {
    func getAllFields(completion: @escaping ([CD_EnrolField]) -> Void) {
        // POC for enrol fields
        fetchCoreDataObjects(forObjectType: CD_EnrolField.self) { enrolFields in
            var fields: [CD_EnrolField] = []
            guard let enrolFields = enrolFields else {
                completion(fields)
                return
            }
            
            let validFields = enrolFields.filter { $0.fieldInputType == .textfield }
            
            for enrolField in validFields {
                if !fields.contains(where: { enrolField.fieldCommonName == $0.fieldCommonName }) {
                    fields.append(enrolField)
                }
            }
            
            completion(fields)
        }
    }
}
