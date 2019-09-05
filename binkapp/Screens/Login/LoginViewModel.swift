//
//  LoginViewModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class LoginViewModel {
    let repository: LoginRepository
    let router: MainScreenRouter

    init(repository: LoginRepository, router: MainScreenRouter) {
        self.repository = repository
        self.router = router
    }

    func registerUser(with email: String) {
        repository.register(email: email, completion: { [weak self] in
            guard let wself = self else { return }
            wself.router.toMainScreen()
        })
    }
}
