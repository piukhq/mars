//
//  ForgotPasswordRepository.swift
//  binkapp
//
//  Created by Paul Tiriteu on 29/11/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

class ForgotPasswordRepository: UserServiceProtocol {
    func continueButtonTapped(email: String, completion: @escaping () -> Void) {
        submitForgotPasswordRequest(forEmailAddress: email) { (_, _) in
            completion()
        }
    }
}
