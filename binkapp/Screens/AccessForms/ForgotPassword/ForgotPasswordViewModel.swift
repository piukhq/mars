//
//  ForgotPasswordViewModel.swift
//  binkapp
//
//  Created by Paul Tiriteu on 29/11/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import UIKit

class ForgotPasswordViewModel {
    private let repository: ForgotPasswordRepository
    
    var navigationController: UINavigationController?
    var email: String?
    
    init(repository: ForgotPasswordRepository) {
        self.repository = repository
    }
    
    func continueButtonTapped() {
        guard let safeEmail = email else { return }
        repository.continueButtonTapped(email: safeEmail, completion: {
            self.displaySimplePopup()
        })
    }
    
    private func displaySimplePopup() {
        let alert = UIAlertController(title: "login_forgot_password".localized, message: "fogrot_password_popup_text".localized, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok".localized, style: .cancel, handler: { _ in
            self.navigationController?.popToRootViewController(animated: true)
        }))
        navigationController?.present(alert, animated: true, completion: nil)
    }
}
