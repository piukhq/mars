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
        dataSource.setupPrefillValueFields()
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
        
        getAllFields()
    }
    
    @objc func saveButtonTapped() {
        print("SAAAAVE")
    }
    
    override func formValidityUpdated(fullFormIsValid: Bool) {
        saveButton.enabled = fullFormIsValid
    }
}

extension PrefillFormValuesViewController: FormDataSourceDelegate {
    func formDataSource(_ dataSource: FormDataSource, textField: UITextField, shouldChangeTo newValue: String?, in range: NSRange, for field: FormField) -> Bool {
        return true
    }
    
    func formDataSource(_ dataSource: FormDataSource, checkboxUpdated: CheckboxView) {
    }
}

extension PrefillFormValuesViewController: FormCollectionViewCellDelegate {
    func formCollectionViewCell(_ cell: FormCollectionViewCell, didSelectField: UITextField) {}
    func formCollectionViewCell(_ cell: FormCollectionViewCell, shouldResignTextField textField: UITextField) {}
}

extension FormDataSource {
    func setupPrefillValueFields() {
        let updatedBlock: FormField.ValueUpdatedBlock = { [weak self] field, newValue in
            guard let self = self else { return }
            self.delegate?.formDataSource(self, changed: newValue, for: field)
        }
        
        let shouldChangeBlock: FormField.TextFieldShouldChange = { [weak self] (field, textField, range, newValue) in
            guard let self = self, let delegate = self.delegate else { return true }
            return delegate.formDataSource(self, textField: textField, shouldChangeTo: newValue, in: range, for: field)
        }
        
//        let pickerUpdatedBlock: FormField.PickerUpdatedBlock = { [weak self] field, options in
//            guard let self = self else { return }
//            self.delegate?.formDataSource(self, selected: options, for: field)
//        }
        
        let fieldExitedBlock: FormField.FieldExitedBlock = { [weak self] field in
            guard let self = self else { return }
            self.delegate?.formDataSource(self, fieldDidExit: field)
        }

//        let manualValidateBlock: FormField.ManualValidateBlock = { [weak self] field in
//            guard let self = self, let delegate = self.delegate else { return false }
//            return delegate.formDataSource(self, manualValidate: field)
//        }
        
//        let emailField = FormField(title: "Email",
//                                   placeholder: "Enter email address",
//                                   validation: nil,
//                                   validationErrorMessage: nil,
//                                   fieldType: .email,
//                                   value: nil,
//                                   updated: updatedBlock,
//                                   shouldChange: shouldChangeBlock,
//                                   fieldExited: fieldExitedBlock,
//                                   pickerSelected: pickerUpdatedBlock,
//                                   columnKind: nil,
//                                   manualValidate: manualValidateBlock,
//                                   forcedValue: nil,
//                                   isReadOnly: false,
//                                   fieldCommonName: .email,
//                                   alternatives: nil,
//                                   dataSourceRefreshBlock: nil)
        
        
        
        let emailField = FormField(
            title: L10n.accessFormEmailTitle,
            placeholder: L10n.accessFormEmailPlaceholder,
            validation: "^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$",
            validationErrorMessage: L10n.accessFormEmailValidation,
            fieldType: .email,
            updated: updatedBlock,
            shouldChange: shouldChangeBlock,
            fieldExited: fieldExitedBlock,
            fieldCommonName: .email
        )
        
        fields = [emailField]
    }
}

extension PrefillFormValuesViewController: CoreDataRepositoryProtocol {
    func getAllFields() {
        // Get all fields and then map an array of all common names
        fetchCoreDataObjects(forObjectType: CD_AddField.self) { addFields in
            print(addFields!)
        }
//        fetchCoreDataObjects(forObjectType: CD_MembershipCard.self) { objects in
//            let scrapableCards = objects?.filter {
//                guard let planIdString = $0.membershipPlan?.id, let planId = Int(planIdString) else { return false }
//                return self.hasAgent(forMembershipPlanId: planId)
//            }
//            completion(scrapableCards)
//        }
    }
}
