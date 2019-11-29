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
    private let router: MainScreenRouter
    
    var navigationController: UINavigationController?
    var email: String = ""
    
    init(repository: ForgotPasswordRepository, router: MainScreenRouter) {
        self.repository = repository
        self.router = router
    }
    
    func continueButtonTapped() {
        repository.continueButtonTapped(email: email, completion: {
            self.displaySimplePopup()
        })
    }
    
    private func displaySimplePopup() {
        let alert = UIAlertController(title: "login_forgot_password".localized, message: "fogrot_password_popup_text".localized, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok".localized, style: .cancel, handler: nil))
        navigationController?.present(alert, animated: true, completion: nil)
    }
}
