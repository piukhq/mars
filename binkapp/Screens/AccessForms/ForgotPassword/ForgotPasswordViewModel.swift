//
//  ForgotPasswordViewModel.swift
//  binkapp
//
//  Created by Paul Tiriteu on 29/11/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import UIKit

class ForgotPasswordViewModel: NSObject {
    let repository: ForgotPasswordRepository
    var email: String?
    var datasource: FormDataSource
    let buttonViewModel: ButtonViewModel
    
    init(repository: ForgotPasswordRepository, datasource: FormDataSource) {
        self.repository = repository
        self.datasource = datasource
        buttonViewModel = ButtonViewModel(datasource: datasource)
        super.init()
        datasource.delegate = self
    }
    
    func continueButtonTapped() {
        buttonViewModel.isLoading = true
        guard let safeEmail = email else { return }
        repository.continueButtonTapped(email: safeEmail, completion: {
            let alert = BinkAlertController(title: L10n.loginForgotPassword, message: L10n.fogrotPasswordPopupText, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: L10n.ok, style: .cancel, handler: { _ in
                Current.navigate.back(toRoot: true, animated: true)
            }))
            let navigationRequest = AlertNavigationRequest(alertController: alert)
            Current.navigate.to(navigationRequest)
        })
    }
}

extension ForgotPasswordViewModel: FormDataSourceDelegate, CheckboxViewDelegate {
    func formDataSource(_ dataSource: FormDataSource, textField: UITextField, shouldChangeTo newValue: String?, in range: NSRange, for field: FormField) -> Bool {
        return true
    }
    
    func formDataSource(_ dataSource: FormDataSource, changed value: String?, for field: FormField) {
        email = value ?? ""
    }
    
    func checkboxView(_ checkboxView: CheckboxView, didCompleteWithColumn column: String, value: String, fieldType: FormField.ColumnKind) {}
    func checkboxView(_ checkboxView: CheckboxView, didTapOn URL: URL) {}
}
