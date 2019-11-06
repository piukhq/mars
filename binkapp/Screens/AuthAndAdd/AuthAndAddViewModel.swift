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
    case login
    case loginFailed
    case signUp
}

class AuthAndAddViewModel {
    private let repository: AuthAndAddRepository
    private let router: MainScreenRouter
    private let membershipPlan: CD_MembershipPlan
    
    private var fieldsViews: [InputValidation] = []
    private var membershipCardPostModel: MembershipCardPostModel?
    private var existingMembershipCard: CD_MembershipCard?
    
    var formPurpose: FormPurpose
    
    var title: String {
        return formPurpose == .signUp ? "sign_up_new_card_title".localized : "log_in_title".localized
    }
    
    var buttonTitle: String {
        return formPurpose == .signUp ? "sign_up_button_title".localized : "log_in_title".localized
    }
    
    var accountButtonShouldHide: Bool {
        return formPurpose != .login
    }
    
    init(repository: AuthAndAddRepository, router: MainScreenRouter, membershipPlan: CD_MembershipPlan, formPurpose: FormPurpose, existingMembershipCard: CD_MembershipCard? = nil) {
        self.repository = repository
        self.router = router
        self.membershipPlan = membershipPlan
        self.membershipCardPostModel = MembershipCardPostModel(account: AccountPostModel(), membershipPlan: Int(membershipPlan.id))
        self.existingMembershipCard = existingMembershipCard
        self.formPurpose = formPurpose
    }
    
    func getDescription() -> String? {
        switch formPurpose {
        case .login:
            guard let planName = membershipPlan.account?.planName else { return nil }
            return String(format: "auth_screen_description".localized, planName)
        case .loginFailed:
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

    func addMembershipCard(with formFields: [FormField], checkboxes: [CheckboxView]? = nil) throws {
        formFields.forEach { addFieldToCard(formField: $0) }
        checkboxes?.forEach { addCheckboxToCard(checkbox: $0) }
                    
        let request = try AddMembershipCardRequest(jsonCard: membershipCardPostModel.asDictionary(), completion: { [weak self] card in
            guard let self = self else {return}
            if let card = card {
                if card.membershipPlan?.featureSet?.planCardType == .link {
                    self.router.toPllViewController(membershipCard: card, journey: .newCard)
                } else {
                    self.router.toLoyaltyFullDetailsScreen(membershipCard: card)
                }
                Current.wallet.refreshLocal()
                NotificationCenter.default.post(name: .didAddMembershipCard, object: nil)
            }
        }, onError: { [weak self] error in
            print(error)
            self?.displaySimplePopup(title: "error_title".localized, message: error.localizedDescription)
        })
        
        repository.addMembershipCard(request: request, formPurpose: formPurpose, existingMembershipCard: existingMembershipCard)
    }
    
    func convertToDictionary(from text: String) throws -> [String: Any]? {
        guard let data = text.data(using: .utf8) else { return [:] }
        let anyResult: Any = try JSONSerialization.jsonObject(with: data, options: [])
        return anyResult as? [String: Any]
    }
    
    func setFields(fields: [InputValidation]) {
        self.fieldsViews = fields
    }
    
    func addFieldToCard(formField: FormField) {
        switch formField.columnKind {
        case .add:
            let addFieldsArray = membershipCardPostModel?.account?.addFields
            if var existingField = addFieldsArray?.first(where: { $0.column == formField.title }) {
                existingField.value = formField.value
            } else {
                membershipCardPostModel?.account?.addFields.append(AddFieldPostModel(column: formField.title, value: formField.value))
            }
        case .auth:
            let authoriseFieldsArray = membershipCardPostModel?.account?.authoriseFields
            if var existingField = authoriseFieldsArray?.first(where: { $0.column == formField.title }) {
                existingField.value = formField.value
            } else {
                membershipCardPostModel?.account?.authoriseFields.append(AuthoriseFieldPostModel(column: formField.title, value: formField.value))
            }
        case .enrol:
            let enrolFieldsArray = membershipCardPostModel?.account?.enrolFields
            if var existingField = enrolFieldsArray?.first(where: { $0.column == formField.title }) {
                existingField.value = formField.value
            } else {
                membershipCardPostModel?.account?.enrolFields.append(EnrolFieldPostModel(column: formField.title, value: formField.value))
            }
        default:
            break
        }
    }
    
    func addCheckboxToCard(checkbox: CheckboxView) {
        switch checkbox.columnKind {
        case .add:
            let addFieldsArray = membershipCardPostModel?.account?.addFields
            if var existingField = addFieldsArray?.first(where: { $0.column == checkbox.title }) {
                existingField.value = String(checkbox.isValid)
            } else {
                membershipCardPostModel?.account?.addFields.append(AddFieldPostModel(column: checkbox.title, value:  String(checkbox.isValid)))
            }
        case .auth:
            let authoriseFieldsArray = membershipCardPostModel?.account?.authoriseFields
            if var existingField = authoriseFieldsArray?.first(where: { $0.column == checkbox.title }) {
                existingField.value = String(checkbox.isValid)
            } else {
                membershipCardPostModel?.account?.authoriseFields.append(AuthoriseFieldPostModel(column: checkbox.title, value: String(checkbox.isValid)))
            }
            
        case .enrol:
            let enrolFieldsArray = membershipCardPostModel?.account?.enrolFields
            if var existingField = enrolFieldsArray?.first(where: { $0.column == checkbox.columnName }) {
                existingField.column = checkbox.columnName
                existingField.value = String(checkbox.isValid)
            } else {
                membershipCardPostModel?.account?.enrolFields.append(EnrolFieldPostModel(column: checkbox.columnName, value: String(checkbox.isValid)))
            }
        default:
            break
        }
    }
    
    func toReusableTemplate(title: String, description: String) {
        let attributedString = NSMutableAttributedString()
        let attributedTitle = NSAttributedString(string: title + "\n", attributes: [NSAttributedString.Key.font : UIFont.headline])
        let attributedBody = NSAttributedString(string: description, attributes: [NSAttributedString.Key.font : UIFont.bodyTextLarge])
        attributedString.append(attributedTitle)
        attributedString.append(attributedBody)
        
        let configuration = ReusableModalConfiguration(title: title, text: attributedString, showCloseButton: true)
        router.toReusableModalTemplateViewController(configurationModel: configuration)
    }
    
    func brandHeaderWasTapped() {
        let title: String = membershipPlan.account?.planNameCard ?? ""
        let description: String = membershipPlan.account?.planDescription ?? ""
        
        toReusableTemplate(title: title, description: description)
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
