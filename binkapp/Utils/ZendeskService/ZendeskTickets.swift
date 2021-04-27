//
//  ZendeskTickets.swift
//  binkapp
//
//  Created by Sean Williams on 19/10/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import Foundation
import SupportSDK

final class ZendeskTickets: NSObject, UITextFieldDelegate {
    private var zendeskPromptFirstNameTextField: UITextField!
    private var zendeskPromptLastNameTextField: UITextField!
    private var zendeskPromptOKAction: UIAlertAction!
    
    func launch() {
        let launchContactUs = {
            let viewController = RequestUi.buildRequestList()
            let navigationRequest = ModalNavigationRequest(viewController: viewController, hideCloseButton: true)
            Current.navigate.to(navigationRequest)
        }
    
        if ZendeskService.shouldPromptForIdentity {
            let alert = BinkAlertController.makeZendeskIdentityAlertController(firstNameTextField: { [weak self] textField in
                self?.zendeskPromptFirstNameTextField = textField
            }, lastNameTextField: { [weak self] textField in
                self?.zendeskPromptLastNameTextField = textField
            }, okActionObject: { [weak self] actionObject in
                self?.zendeskPromptOKAction = actionObject
            }, okActionHandler: {
                launchContactUs()
            }, textFieldDelegate: self)
            let navigationRequest = AlertNavigationRequest(alertController: alert)
            Current.navigate.to(navigationRequest)
        } else {
            launchContactUs()
        }
    }
    
    internal func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        /// If both textfields are empty, disable ok action as at least one textfield will be empty after updating
        let firstNameText = zendeskPromptFirstNameTextField.text ?? ""
        let lastNameText = zendeskPromptLastNameTextField.text ?? ""
        if firstNameText.isEmpty && lastNameText.isEmpty {
            zendeskPromptOKAction.isEnabled = false
        }
        /// If both textfields are NOT empty, and the replacement string is NOT empty, we know that both textfields must have values after updating
        if !firstNameText.isEmpty && !lastNameText.isEmpty && !string.isEmpty {
            zendeskPromptOKAction.isEnabled = true
        }

        /// If the textfield being updated is firstName, and it has no current value, and the replacement string has a value, and lastName has a value then we know that both textfields will have values after updating
        if textField == zendeskPromptFirstNameTextField && firstNameText.isEmpty && !string.isEmpty && !lastNameText.isEmpty {
            zendeskPromptOKAction.isEnabled = true
        }

        /// If the textfield being updated is lastName, and it has no current value, and the replacement string has a value, and firstName has a value then we know that both textfields will have values after updating
        if textField == zendeskPromptLastNameTextField && lastNameText.isEmpty && !string.isEmpty && !firstNameText.isEmpty {
            zendeskPromptOKAction.isEnabled = true
        }

        /// If the textfield being updated is firstName, and it's current value is only one character, and the replacement string has no value then we know the textfield will have no value after updating
        if textField == zendeskPromptFirstNameTextField && firstNameText.count == 1 && string.isEmpty {
            zendeskPromptOKAction.isEnabled = false
        }

        /// If the textfield being updated is lastName, and it's current value is only one character, and the replacement string has no value then we know the textfield will have no value after updating
        if textField == zendeskPromptLastNameTextField && lastNameText.count == 1 && string.isEmpty {
            zendeskPromptOKAction.isEnabled = false
        }

        return true
    }
}

extension UIAlertController {
    static func makeZendeskIdentityAlertController(firstNameTextField: @escaping (UITextField) -> Void, lastNameTextField: @escaping (UITextField) -> Void, okActionObject: (UIAlertAction) -> Void, okActionHandler: @escaping () -> Void, textFieldDelegate: UITextFieldDelegate?) -> BinkAlertController {
        let alert = BinkAlertController(title: nil, message: L10n.zendeskIdentityPromptMessage, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = L10n.zendeskIdentityPromptFirstName
            textField.autocapitalizationType = .words
            textField.delegate = textFieldDelegate
            firstNameTextField(textField)
        }
        alert.addTextField { textField in
            textField.placeholder = L10n.zendeskIdentityPromptLastName
            textField.autocapitalizationType = .words
            textField.delegate = textFieldDelegate
            lastNameTextField(textField)
        }
        let cancelAction = UIAlertAction(title: L10n.cancel, style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: L10n.ok, style: .default) { _ in
            let firstName = alert.textFields?[0].text
            let lastName = alert.textFields?[1].text
            let request = BinkNetworkRequest(endpoint: .me, method: .put, headers: nil, isUserDriven: false)
            let params = UserProfileUpdateRequest(firstName: firstName, lastName: lastName)
            Current.apiClient.performRequestWithBody(request, body: params, expecting: UserProfileResponse.self) { (result, _) in
                guard let response = try? result.get() else { return }
                /// Don't update Zendesk identity, as we do this with the textField input values, and do not need to set it twice.
                Current.userManager.setProfile(withResponse: response, updateZendeskIdentity: false)
            }

            /// Use raw input to move forward with new zendesk identity
            ZendeskService.setIdentity(firstName: firstName, lastName: lastName)
            okActionHandler()
        }
        okAction.isEnabled = false
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        okActionObject(okAction)
        return alert
    }
}
