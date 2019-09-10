//
//  AuthAndAddViewModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import UIKit

enum FieldType {
    case add
    case authorise
}

enum FieldInputType: Int {
    case textfield = 0
    case password
    case dropdown
    case checkbox
}

class AuthAndAddViewModel {
    private let repository: AuthAndAddRepository
    private let router: MainScreenRouter
    private let membershipPlan: MembershipPlanModel
    
    private var fieldsViews: [InputValidation] = []
    private var membershipCard: MembershipCardPostModel?
    
    init(repository: AuthAndAddRepository, router: MainScreenRouter, membershipPlan: MembershipPlanModel) {
        self.repository = repository
        self.router = router
        self.membershipPlan = membershipPlan
        self.membershipCard = MembershipCardPostModel(account: AccountPostModel(addFields: [], authoriseFields: []), membershipPlan: membershipPlan.id)
    }
    
    func getMembershipPlan() -> MembershipPlanModel {
        return membershipPlan
    }
    
    func addMembershipCard() {
        let jsonEncoder = JSONEncoder()
        let jsonData = try! jsonEncoder.encode(membershipCard)
        if let jsonCard = String(data: jsonData, encoding: String.Encoding.utf8) {
            do {
                let result = try convertToDictionary(from: jsonCard) ?? [:]
                repository.addMembershipCard(jsonCard: result, completion: { response in
                    self.router.toPllViewController(membershipCard: response, membershipPlan: self.membershipPlan)
                })
            } catch {
                print(error)
            }
        }
    }

    func convertToDictionary(from text: String) throws -> [String: Any]? {
        guard let data = text.data(using: .utf8) else { return [:] }
        let anyResult: Any = try JSONSerialization.jsonObject(with: data, options: [])
        return anyResult as? [String: Any]
    }
    
    func populateStackView(stackView: UIStackView) {
        var checkboxes: [CheckboxView] = []
        if let addFields = membershipPlan.account?.addFields {
            for field in addFields {
                switch field.type {
                    case FieldInputType.textfield.rawValue:
                        let view = LoginTextFieldView()
                        view.configure(title: field.column ?? "", placeholder: field.description, validationRegEx: field.validation ?? "", fieldType: .add, delegate: self)
                        fieldsViews.append(view)
                    case FieldInputType.password.rawValue:
                        let view = LoginTextFieldView()
                        view.configure(title: field.column ?? "", placeholder: field.description, validationRegEx: field.validation ?? "", isPassword: true, fieldType: .add, delegate: self)
                        fieldsViews.append(view)
                    case FieldInputType.dropdown.rawValue:
                        let view = DropdownView()
                        view.configure(title: field.column ?? "", choices: field.choice ?? [], fieldType: .add, delegate: self)
                        fieldsViews.append(view)
                    case FieldInputType.checkbox.rawValue:
                        let view = CheckboxView()
                        view.configure(title: field.description ?? "", fieldType: .add)
                        checkboxes.append(view)
                    default: break
                }
            }
        }
        
        if let authoriseFields = membershipPlan.account?.authoriseFields {
            for field in authoriseFields {
                switch field.type {
                case FieldInputType.textfield.rawValue:
                    let view = LoginTextFieldView()
                    view.configure(title: field.column ?? "", placeholder: field.description, validationRegEx: field.validation ?? "", fieldType: .authorise, delegate: self)
                    fieldsViews.append(view)
                case FieldInputType.password.rawValue:
                    let view = LoginTextFieldView()
                    view.configure(title: field.column ?? "", placeholder: field.description, validationRegEx: field.validation ?? "", isPassword: true, fieldType: .authorise, delegate: self)
                    fieldsViews.append(view)
                case FieldInputType.dropdown.rawValue:
                    let view = DropdownView()
                    view.configure(title: field.column ?? "", choices: field.choice ?? [], fieldType: .authorise, delegate: self)
                    fieldsViews.append(view)
                case FieldInputType.checkbox.rawValue:
                    let view = CheckboxView()
                    view.configure(title: field.description ?? "", fieldType: .authorise)
                    checkboxes.append(view)
                default: break
                }
            }
        }
        
        for box in checkboxes {
            fieldsViews.append(box)
        }
        
        if fieldsViews.isEmpty == false {
            for view in fieldsViews {
                if view is UIView {
                    stackView.addArrangedSubview(view as! UIView)
                }
            }
        }
    }
    
    func allFieldsAreValid() -> Bool {
        for field in fieldsViews {
            if !field.isValid {
                return false
            }
        }
        return true
    }
    
    func addFieldToCard(column: String, value: String, fieldType: FieldType) {
        switch fieldType {
        case .add:
            let addFieldsArray = membershipCard?.account?.addFields
            if var existingField = addFieldsArray?.first(where: { $0.column == column }) {
                existingField.column = column
                existingField.value = value
            } else {
                membershipCard?.account?.addFields?.append(AddFieldPostModel(column: column, value: value))
            }
        case .authorise:
            let authoriseFieldsArray = membershipCard?.account?.authoriseFields
            if var existingField = authoriseFieldsArray?.first(where: { $0.column == column }) {
                existingField.column = column
                existingField.value = value
            } else {
                membershipCard?.account?.authoriseFields?.append(AuthoriseFieldPostModel(column: column, value: value))
            }
        }
    }
    
    func displaySimplePopup(title: String?, message: String?) {
        router.displaySimplePopup(title: title, message: message)
    }

    func popViewController() {
        router.popViewController()
    }
    
    func popToRootViewController() {
        router.popToRootViewController()
    }
}

extension AuthAndAddViewModel: LoginTextFieldDelegate {
    func loginTextFieldView(_ loginTextFieldView: LoginTextFieldView, didCompleteWithColumn column: String, value: String, fieldType: FieldType) {
        addFieldToCard(column: column, value: value, fieldType: fieldType)
    }
}

extension AuthAndAddViewModel: DropdownDelegate {
    func dropdownView(_ dropdownView: DropdownView, didSetDataWithColumn column: String, value: String, fieldType: FieldType) {
        addFieldToCard(column: column, value: value, fieldType: fieldType)
    }
}
