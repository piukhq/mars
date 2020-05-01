//
//  AppleAuthController.swift
//  binkapp
//
//  Created by Nick Farrant on 30/04/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import Foundation
import AuthenticationServices

@available(iOS 13.0, *)
final class AppleAuthController: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
//    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
//        return self.view.window
//    }

    struct SignInWithAppleRequest: Codable {
        let authorizationCode: String

        enum CodingKeys: String, CodingKey {
            case authorizationCode = "authorization_code"
        }
    }

    @objc func handleAppleIdRequest() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.email]
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }

    // MARK: - ASAuthorizationControllerDelegate

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else { return }
        guard let authCodeData = appleIDCredential.authorizationCode else { return }
        let authCodeString = String(decoding: authCodeData, as: UTF8.self)
        signInWithApple(authCode: authCodeString)
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print(error.localizedDescription)
    }

    // MARK: Networking

    private func signInWithApple(authCode: String) {
        let request = SignInWithAppleRequest(authorizationCode: authCode)
        
    }
}
