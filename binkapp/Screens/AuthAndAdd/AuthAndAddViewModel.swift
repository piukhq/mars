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
    case add
    case addFailed
    case signUp
    case signUpFailed
    case ghostCard
    case patchGhostCard
    
    var planDocumentDisplayMatching: PlanDocumentDisplayModel {
        switch self {
        case .add, .addFailed:
            return .add
        case .signUp, .signUpFailed:
            return .enrol
        case .ghostCard, .patchGhostCard:
            return .registration
        }
    }
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
        switch formPurpose {
        case .signUp, .signUpFailed: return "sign_up_new_card_title".localized
        case .add: return "credentials_title".localized
        case .addFailed: return "log_in_title".localized
        case .ghostCard, .patchGhostCard: return "register_ghost_card_title".localized
        }
    }
    
    var buttonTitle: String {
        switch formPurpose {
        case .signUp, .signUpFailed: return "sign_up_button_title".localized
        case .add, .addFailed: return "pll_screen_add_title".localized
        case .ghostCard, .patchGhostCard: return "register_card_title".localized
        }
    }
    
    var accountButtonShouldHide: Bool {
        return formPurpose != .add || formPurpose == .ghostCard
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
        case .add:
            guard let companyName = membershipPlan.account?.companyName else { return nil }
            return String(format: "auth_screen_description".localized, companyName)
        case .signUp:
            guard let planNameCard = membershipPlan.account?.planNameCard else { return nil }
            return String(format: "sign_up_new_card_description".localized, planNameCard)
        case .ghostCard, .patchGhostCard:
            guard let planNameCard = membershipPlan.account?.planNameCard else { return nil }
            return String(format: "register_ghost_card_description".localized, planNameCard)
        case .addFailed, .signUpFailed:
            return getDescriptionForOtherLogin()
        }
    }
    
    private func getDescriptionForOtherLogin() -> String {
        guard let planNameCard = membershipPlan.account?.planNameCard else { return "" }
        
        if hasPoints() {
            guard let transactionsAvailable = membershipPlan.featureSet?.transactionsAvailable else {
                return String(format: "only_points_log_in_description".localized, planNameCard)
            }
            
            return transactionsAvailable.boolValue ? String(format: "points_and_transactions_log_in_description".localized, planNameCard) : String(format: "only_points_log_in_description".localized, planNameCard)
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

    func addMembershipCard(with formFields: [FormField], checkboxes: [CheckboxView]? = nil, completion: @escaping () -> Void) throws {
        guard formPurpose != .ghostCard, formPurpose != .patchGhostCard else {
            try addGhostCard(with: formFields, checkboxes: checkboxes, existingMembershipCard: existingMembershipCard)
            return
        }
        
        formFields.forEach { addFieldToCard(formField: $0) }
        checkboxes?.forEach { addCheckboxToCard(checkbox: $0) }

        guard let model = membershipCardPostModel else { return }
                
        repository.addMembershipCard(request: model, formPurpose: formPurpose, existingMembershipCard: existingMembershipCard, onSuccess: { [weak self] card in
            guard let self = self else {return}
            if let card = card {
                if card.membershipPlan?.featureSet?.planCardType == .link {
                    self.router.toPllViewController(membershipCard: card, journey: .newCard)
                } else {
                    self.router.toLoyaltyFullDetailsScreen(membershipCard: card)
                }
                completion()
                Current.wallet.refreshLocal()
                NotificationCenter.default.post(name: .didAddMembershipCard, object: nil)
            }
            }, onError: { [weak self] error in
                guard let customError = error as? CustomError else {
                    self?.displaySimplePopup(title: "error_title".localized, message: error?.localizedDescription)
                    completion()
                    return
                }
                self?.displaySimplePopup(title: "error_title".localized, message: customError.localizedDescription)
                completion()
        })
    }
    
    private func addGhostCard(with formFields: [FormField], checkboxes: [CheckboxView]? = nil, existingMembershipCard: CD_MembershipCard?) throws {
        
        // Setup with both
        populateCard(with: formFields, checkboxes: checkboxes, columnKind: .add)
        populateCard(with: formFields, checkboxes: checkboxes, columnKind: .register)
        
        guard var model = membershipCardPostModel else {
            return
        }
        
        if existingMembershipCard != nil {
            model.membershipPlan = nil
        }
        
        repository.postGhostCard(parameters: model, existingMembershipCard: existingMembershipCard, onSuccess: { [weak self] (response) in
            guard let card = response else {
                Current.wallet.refreshLocal()
                NotificationCenter.default.post(name: .didAddMembershipCard, object: nil)
                return
            }
            
            if card.membershipPlan?.featureSet?.cardType == 2 {
                self?.router.toPllViewController(membershipCard: card, journey: .newCard)
            } else {
                self?.router.toLoyaltyFullDetailsScreen(membershipCard: card)
            }
//<<<<<<< HEAD
//
//
//            if self?.existingMembershipCard == nil {
//                self?.populateCard(with: formFields, checkboxes: checkboxes, columnKind: .register)
//                var registrationCard = model
//                registrationCard.account?.addFields = []
//                self?.repository.patchGhostCard(cardId: card.id, parameters: registrationCard)
//            }
//
//            Current.wallet.refreshLocal()
//            NotificationCenter.default.post(name: .didAddMembershipCard, object: nil)
//=======
//>>>>>>> develop
        }) { (error) in
            self.displaySimplePopup(title: "error_title".localized, message: error?.localizedDescription)
        }
    }
    
    private func populateCard(with formFields: [FormField], checkboxes: [CheckboxView]? = nil, columnKind: FormField.ColumnKind) {
        formFields.forEach {
            if $0.columnKind == columnKind {
                addFieldToCard(formField: $0)
            }
        }
        checkboxes?.forEach {
            if $0.columnKind == columnKind && $0.columnKind != FormField.ColumnKind.planDocument {
                addCheckboxToCard(checkbox: $0)
            }
        }
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
                let model = PostModel(column: formField.title, value: formField.value)
                membershipCardPostModel?.account?.addField(model, to: .add)
            }
        case .auth:
            let authoriseFieldsArray = membershipCardPostModel?.account?.authoriseFields
            if var existingField = authoriseFieldsArray?.first(where: { $0.column == formField.title }) {
                existingField.value = formField.value
            } else {
                let model = PostModel(column: formField.title, value: formField.value)
                membershipCardPostModel?.account?.addField(model, to: .auth)
            }
        case .enrol:
            let enrolFieldsArray = membershipCardPostModel?.account?.enrolFields
            if var existingField = enrolFieldsArray?.first(where: { $0.column == formField.title }) {
                existingField.value = formField.value
            } else {
                let model = PostModel(column: formField.title, value: formField.value)
                membershipCardPostModel?.account?.addField(model, to: .enrol)
            }
            
        case .register:
            let registrationFieldsArray = membershipCardPostModel?.account?.registrationFields
            if var existingField = registrationFieldsArray?.first(where: { $0.column == formField.title }) {
                existingField.value = formField.value
            } else {
                let model = PostModel(column: formField.title, value: formField.value)
                membershipCardPostModel?.account?.addField(model, to: .registration)
            }
        default:
            break
        }
    }
    
    func addCheckboxToCard(checkbox: CheckboxView) {
        switch checkbox.columnKind {
        case .add:
            let addFieldsArray = membershipCardPostModel?.account?.addFields
            if var existingField = addFieldsArray?.first(where: { $0.column == checkbox.columnName }) {
                existingField.value = String(checkbox.isValid)
            } else {
                let model = PostModel(column: checkbox.columnName, value: String(checkbox.isValid))
                membershipCardPostModel?.account?.addField(model, to: .add)
            }
        case .auth:
            let authoriseFieldsArray = membershipCardPostModel?.account?.authoriseFields
            if var existingField = authoriseFieldsArray?.first(where: { $0.column == checkbox.columnName }) {
                existingField.value = String(checkbox.isValid)
            } else {
                let model = PostModel(column: checkbox.columnName, value: String(checkbox.isValid))
                membershipCardPostModel?.account?.addField(model, to: .auth)
            }
        case .enrol:
            let enrolFieldsArray = membershipCardPostModel?.account?.enrolFields
            if var existingField = enrolFieldsArray?.first(where: { $0.column == checkbox.columnName }) {
                existingField.value = String(checkbox.isValid)
            } else {
                let model = PostModel(column: checkbox.columnName, value: String(checkbox.isValid))
                membershipCardPostModel?.account?.addField(model, to: .enrol)
            }
        case .register:
            let registerFieldsArray = membershipCardPostModel?.account?.registrationFields
            if var existingField = registerFieldsArray?.first(where: { $0.column == checkbox.columnName }) {
                existingField.value = String(checkbox.isValid)
            } else {
                let model = PostModel(column: checkbox.columnName, value: String(checkbox.isValid))
                membershipCardPostModel?.account?.addField(model, to: .registration)
            }
        default:
            break
        }
    }
    
    func reloadWithGhostCardFields() {
        let newFormPurpose: FormPurpose = formPurpose == .addFailed ? .patchGhostCard : .ghostCard
        router.toAuthAndAddViewController(membershipPlan: membershipPlan, formPurpose: newFormPurpose, existingMembershipCard: existingMembershipCard)
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
        let title = membershipPlan.account?.planName ?? ""
        let description = membershipPlan.account?.planDescription ?? ""
        
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
