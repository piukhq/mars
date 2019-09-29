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
       return MembershipCardPostModel(account: AccountPostModel(addFields: [], authoriseFields: []), membershipPlan: nil)
    }()
    
    init(repository: AuthAndAddRepository, router: MainScreenRouter, membershipPlan: CD_MembershipPlan) {
        self.repository = repository
        self.router = router
        self.membershipPlan = membershipPlan
        membershipCard.membershipPlan = Int(membershipPlan.id)
    }
    
    func getMembershipPlan() -> CD_MembershipPlan {
        return membershipPlan
    }
    
    func addMembershipCard(with formFields: [FormField]) {
        
        formFields.forEach {
            addFieldToCard(formField: $0)
        }
                        
        try? repository.addMembershipCard(jsonCard: membershipCard.asDictionary(), completion: { card in
            if let card = card {
                self.router.toPllViewController(membershipCard: card)
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
