//
//  LoginViewController.swift
//  binkapp
//
//  Copyright (c) 2019 Bink. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    let viewModel: LoginViewModel
    private let fallbackUserEmail = "Bink20iteration1@testbink.com"

    private var userEmail: String {
        guard let userEmail = Current.userDefaults.string(forKey: "userEmail") else {
            Current.userDefaults.set(fallbackUserEmail, forKey: "userEmail")
            return fallbackUserEmail
        }
        return userEmail
    }
    
    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "LoginViewController", bundle: Bundle(for: LoginViewController.self))
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewModel.registerUser(with: userEmail)
    }
}
