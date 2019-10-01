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
    
    var isFirstAuth: Bool
    
    init(repository: AuthAndAddRepository, router: MainScreenRouter, membershipPlan: MembershipPlanModel, isFirstAuth: Bool = true) {
        self.repository = repository
        self.router = router
        self.membershipPlan = membershipPlan
        self.membershipCard = MembershipCardPostModel(account: AccountPostModel(addFields: [], authoriseFields: []), membershipPlan: membershipPlan.id)
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
            
            return transactionsAvailable ? String(format: "only_points_log_in_description".localized, companyName) : String(format: "points_and_transactions_log_in_description".localized, companyName)
        } else {
            return ""
        }
    }
    
    private func hasPoints() -> Bool {
        guard let hasPoints = membershipPlan.featureSet?.hasPoints else { return false }
        return hasPoints
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
                    NotificationCenter.default.post(name: .didAddMembershipCard, object: nil)
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
    
    func getAddFields() -> [AddFieldModel] {
        guard let fields = membershipPlan.account?.addFields else { return [] }
        return isFirstAuth ? fields : []
    }
    
    func getAuthorizeFields() -> [AuthoriseFieldModel] {
        guard let fields = membershipPlan.account?.authoriseFields else { return [] }
        return fields
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

extension AuthAndAddViewModel: DropdownDelegate {
    func dropdownView(_ dropdownView: DropdownView, didSetDataWithColumn column: String, value: String, fieldType: FieldType) {
        addFieldToCard(column: column, value: value, fieldType: fieldType)
    }
}
