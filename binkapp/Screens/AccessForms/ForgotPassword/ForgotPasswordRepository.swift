//
//  ForgotPasswordRepository.swift
//  binkapp
//
//  Created by Paul Tiriteu on 29/11/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

class ForgotPasswordRepository {
    private let apiClient: APIClient
    
    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }
    
    func continueButtonTapped(email: String, completion: @escaping () -> Void) {
        apiClient.performRequestWithNoResponse(onEndpoint: .forgotPassword, using: .post, parameters: ["email": email], isUserDriven: true) { (_, _) in
            completion()
        }
    }
}
