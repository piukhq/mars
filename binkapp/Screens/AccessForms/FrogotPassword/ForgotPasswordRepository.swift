//
//  ForgotPasswordRepository.swift
//  binkapp
//
//  Created by Paul Tiriteu on 29/11/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

class ForgotPasswordRepository {
    private let apiManager: ApiManager
    
    init(apiManager: ApiManager) {
        self.apiManager = apiManager
    }
    
    func continueButtonTapped(email: String, completion: @escaping () -> Void) {
        let model = ForgotPasswordModel(email: email)
        apiManager.doRequest(url: .forgotPassword, httpMethod: .post, parameters: model, onSuccess: { (response: EmptyResponse) in
            completion()
        }) { _ in
            completion()
        }
    }
}
