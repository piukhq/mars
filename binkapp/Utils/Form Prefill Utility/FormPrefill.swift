//
//  FormPrefill.swift
//  binkapp
//
//  Created by Nick Farrant on 14/05/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import UIKit

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
        let values = dataSource.currentFieldValues()
        Current.userDefaults.set(values, forDefaultsKey: .prefilledFormValues)
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
        
        let prefilledValues = Current.userDefaults.value(forDefaultsKey: .prefilledFormValues) as? [String: String]
        
        enrolFields.forEach { field in
            var forcedValue: String? = ""
            if let column = field.column?.lowercased() {
                forcedValue = prefilledValues?[column]
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

protocol PrefilledValuesFormInputAccessoryDelegate: AnyObject {
    func inputAccessory(_ inputAccessory: PrefilledValuesFormInputAccessory, didSelectValue value: String)
}

class PrefilledValuesFormInputAccessory: UIToolbar, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    private let field: FormField
    private weak var valueDelegate: PrefilledValuesFormInputAccessoryDelegate?
    
    init(field: FormField, delegate: PrefilledValuesFormInputAccessoryDelegate) {
        self.field = field
        self.valueDelegate = delegate
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
    
    var prefilledValues: [String]? {
        let allPrefilledValues = Current.userDefaults.value(forDefaultsKey: .prefilledFormValues) as? [String: String]
        let value = allPrefilledValues?[field.title.lowercased()]
        if let value = value {
            return [value]
        }
        return nil
    }
    
    private func configure() {
        collectionView.register(PrefilledFormValueInputCell.self, asNib: false)
        addSubview(collectionView)
        collectionView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        collectionView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return prefilledValues?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: PrefilledFormValueInputCell = collectionView.dequeue(indexPath: indexPath)
        guard let value = prefilledValues?[indexPath.row] else { return cell }
        cell.configureWithValue(value)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let value = prefilledValues?[indexPath.row] {
            valueDelegate?.inputAccessory(self, didSelectValue: value)
        }
    }
}

class PrefilledFormValueInputCell: UICollectionViewCell {
    private lazy var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        label.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        label.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
        label.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
        return label
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
    }
    
    func configureWithValue(_ value: String) {
        label.text = value
        backgroundColor = .systemGray5
        layer.cornerCurve = .continuous
        layer.cornerRadius = 4
    }
}
