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
        let request = BinkNetworkRequest(endpoint: .forgotPassword, method: .post, headers: nil, isUserDriven: true)
        apiClient.performRequestWithNoResponse(request, parameters: ["email": email]) { (_, _) in
            completion()
        }
    }
}
