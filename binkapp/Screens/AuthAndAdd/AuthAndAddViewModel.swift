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
    case enrol
}

enum InputType: Int {
    case textfield = 0
    case password
    case dropdown
    case checkbox
}

enum FormPurpose {
    case firstLogin
    case otherLogin
    case signUp
}

class AuthAndAddViewModel {
    private let repository: AuthAndAddRepository
    private let router: MainScreenRouter
    private let membershipPlan: CD_MembershipPlan
    private let membershipPlanId: Int
    
    private var fieldsViews: [InputValidation] = []
    private lazy var membershipCard: MembershipCardPostModel = {
       return MembershipCardPostModel(account: AccountPostModel(addFields: [], authoriseFields: []), membershipPlan: membershipPlanId)
    }()
    
    var formPurpose: FormPurpose
    
    var title: String {
        return formPurpose == .signUp ? "sign_up_new_card_title".localized : "log_in_title".localized
    }
    
    var buttonTitle: String {
        return formPurpose == .signUp ? "sign_up_button_title".localized : "log_in_title".localized
    }
    
    init(repository: AuthAndAddRepository, router: MainScreenRouter, membershipPlan: CD_MembershipPlan, formPurpose: FormPurpose) {
        self.repository = repository
        self.router = router
        self.membershipPlan = membershipPlan
        self.membershipCard = MembershipCardPostModel(account: AccountPostModel(addFields: [], authoriseFields: [], enrolFields: []), membershipPlan: membershipPlan.id)
        self.formPurpose = formPurpose
        membershipPlanId = Int(membershipPlan.id)!
    }
    
    func getDescription() -> String? {
        switch formPurpose {
        case .firstLogin:
            guard let planName = membershipPlan.account?.planName else { return nil }
            return String(format: "auth_screen_description".localized, planName)
        case .otherLogin:
            return getDescriptionForOtherLogin()
        case .signUp:
            guard let companyName = membershipPlan.account?.companyName else { return nil }
            return String(format: "sign_up_new_card_description".localized, companyName)
        }
    }
    
    private func getDescriptionForOtherLogin() -> String {
        guard let planNameCard = membershipPlan.account?.planNameCard else { return "" }
        
        if hasPoints() {
            guard let transactionsAvailable = membershipPlan.featureSet?.transactionsAvailable else {
                return String(format: "only_points_log_in_description".localized, planNameCard)
            }
            
            return transactionsAvailable.boolValue ? String(format: "only_points_log_in_description".localized, planNameCard) : String(format: "points_and_transactions_log_in_description".localized, planNameCard)
        } else {
            return ""
        }
    }
    
    private func hasPoints() -> Bool {
        guard let hasPoints = membershipPlan.featureSet?.hasPoints else { return false }
        return hasPoints.boolValue
    }
    
    func getMembershipPlan() -> CD_MembershipPlan {
        return membershipPlan
    }
    
//    func addMembershipCard() {
//        let jsonEncoder = JSONEncoder()
//        let jsonData = try! jsonEncoder.encode(membershipCard)
//        if let jsonCard = String(data: jsonData, encoding: String.Encoding.utf8) {
//            do {
//                let result = try convertToDictionary(from: jsonCard) ?? [:]
//                repository.addMembershipCard(jsonCard: result, completion: { response in
//                    // TODO: Add condition here after server work is done.
//                    self.router.toPllViewController(membershipCard: response, membershipPlan: self.membershipPlan)
//                    NotificationCenter.default.post(name: .didAddMembershipCard, object: nil)
//                }, onError: { (error) in
//                    self.router.displaySimplePopup(title: "error_title".localized, message: error.localizedDescription)
//                })
//            } catch {
//                print(error)
//            }
//        }
//    }

    func addMembershipCard(with formFields: [FormField], checkboxes: [CheckboxView]? = nil) {
        formFields.forEach { addFieldToCard(formField: $0) }
        checkboxes?.forEach { addCheckboxToCard(checkbox: $0) }
                        
        try? repository.addMembershipCard(jsonCard: membershipCard.asDictionary(), completion: { card in
            if let card = card {
                self.router.toPllViewController(membershipCard: card)
                NotificationCenter.default.post(name: .didAddMembershipCard, object: nil)
            }
        })
    }

    func convertToDictionary(from text: String) throws -> [String: Any]? {
        guard let data = text.data(using: .utf8) else { return [:] }
        let anyResult: Any = try JSONSerialization.jsonObject(with: data, options: [])
        return anyResult as? [String: Any]
    }
    
    func getAddFields() -> [AddFieldModel] {
        guard let fields = membershipPlan.account?.addFields else { return [] }
        return formPurpose == .firstLogin ? fields : []
    }
    
    func getAuthorizeFields() -> [AuthoriseFieldModel] {
        guard let fields = membershipPlan.account?.authoriseFields else { return [] }
        return formPurpose != .signUp ? fields : []
    }
    
    func getEnrolFields() -> [EnrolFieldModel] {
        guard let fields = membershipPlan.account?.enrolFields else { return [] }
        return formPurpose == .signUp ? fields : []
    }
    
    func setFields(fields: [InputValidation]) {
        self.fieldsViews = fields
    
    func addFieldToCard(formField: FormField) {
        switch formField.columnKind {
        case .add:
            let addFieldsArray = membershipCard.account?.addFields
            if var existingField = addFieldsArray?.first(where: { $0.column == formField.title }) {
                existingField.value = formField.value
                existingField.value = formField.value
            } else {
                membershipCard.account?.addFields?.append(AddFieldPostModel(column: formField.title, value: formField.value))
            }
        case .auth:
            let authoriseFieldsArray = membershipCard.account?.authoriseFields
            if var existingField = authoriseFieldsArray?.first(where: { $0.column == formField.title }) {
                existingField.value = formField.value
            } else {
                membershipCard.account?.authoriseFields?.append(AuthoriseFieldPostModel(column: formField.title, value: formField.value))
            }
        default:
            break
        }
    }
    
    func addCheckboxToCard(checkbox: CheckboxView) {
        switch checkbox.columnKind {
        case .add:
            let addFieldsArray = membershipCard.account?.addFields
            if var existingField = addFieldsArray?.first(where: { $0.column == checkbox.title }) {
                existingField.value = String(checkbox.isValid())
            } else {
                membershipCard.account?.addFields?.append(AddFieldPostModel(column: checkbox.title, value:  String(checkbox.isValid())))
            }
        case .auth:
            let authoriseFieldsArray = membershipCard.account?.authoriseFields
            if var existingField = authoriseFieldsArray?.first(where: { $0.column == checkbox.title }) {
                existingField.value = String(checkbox.isValid())
            } else {
                membershipCard.account?.authoriseFields?.append(AuthoriseFieldPostModel(column: checkbox.title, value: String(checkbox.isValid())))
            }
            
        case .enrol:
            let enrolFieldsArray = membershipCard?.account?.enrolFields
            if var existingField = enrolFieldsArray?.first(where: { $0.column == column }) {
                existingField.column = column
                existingField.value = value
            } else {
                membershipCard?.account?.enrolFields?.append(EnrolFieldPostModel(column: column, value: value))
            }
        default:
            break
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
