//
//  LoginViewModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class LoginViewModel {
    let repository: LoginRepository

    init(repository: LoginRepository) {
        self.repository = repository
    }

    func registerUser(with email: String) {
        repository.reigster(email: email)
    }
}
