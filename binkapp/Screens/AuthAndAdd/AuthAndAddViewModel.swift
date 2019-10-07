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

enum InputType: Int {
    case textfield = 0
    case password
    case dropdown
    case checkbox
}

class AuthAndAddViewModel {
    private let repository: AuthAndAddRepository
    private let router: MainScreenRouter
    private let membershipPlan: CD_MembershipPlan
    
    private var fieldsViews: [InputValidation] = []
    private lazy var membershipCard: MembershipCardPostModel = {
       return MembershipCardPostModel(account: AccountPostModel(addFields: [], authoriseFields: []), membershipPlan: membershipPlanId)
    }()
    
    private var isFirstAuth: Bool
    private let membershipPlanId: Int
    
    init(repository: AuthAndAddRepository, router: MainScreenRouter, membershipPlan: CD_MembershipPlan, isFirstAuth: Bool = true) {
        self.repository = repository
        self.router = router
        self.membershipPlan = membershipPlan
        membershipPlanId = Int(membershipPlan.id)!
        self.isFirstAuth = isFirstAuth
    }
    
    func getDescription() -> String? {
        guard let planName = membershipPlan.account?.planName else { return nil }
        
        return isFirstAuth ? String(format: "auth_screen_description".localized, planName) : getDescriptionText()
    }
    
    private func getDescriptionText() -> String {
        guard let companyName = membershipPlan.account?.planNameCard else { return "" }
        
        if hasPoints() {
            guard let transactionsAvailable = membershipPlan.featureSet?.transactionsAvailable else {
                return String(format: "only_points_log_in_description".localized, companyName)
            }
            
            return transactionsAvailable.boolValue ? String(format: "only_points_log_in_description".localized, companyName) : String(format: "points_and_transactions_log_in_description".localized, companyName)
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
    
    func addMembershipCard(with formFields: [FormField], checkboxes: [CheckboxView]? = nil) {
        formFields.forEach { addFieldToCard(formField: $0) }
        checkboxes?.forEach { addCheckboxToCard(checkbox: $0) }
                        
        try? repository.addMembershipCard(jsonCard: membershipCard.asDictionary(), completion: { card in
            if let card = card {
                self.router.toPllViewController(membershipCard: card, membershipPlan: self.membershipPlan)
                NotificationCenter.default.post(name: .didAddMembershipCard, object: nil)
            }
        })
    }
    
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
            print()
            let authoriseFieldsArray = membershipCard.account?.authoriseFields
            if var existingField = authoriseFieldsArray?.first(where: { $0.column == checkbox.title }) {
                existingField.value = String(checkbox.isValid())
            } else {
                membershipCard.account?.authoriseFields?.append(AuthoriseFieldPostModel(column: checkbox.title, value: String(checkbox.isValid())))
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
