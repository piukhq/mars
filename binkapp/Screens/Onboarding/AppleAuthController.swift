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
final class AppleAuthController: NSObject, ASAuthorizationControllerDelegate {
    @objc func handleAppleIdRequest() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.performRequests()
    }

    // MARK: - ASAuthorizationControllerDelegate

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else { return }
        continueWithApple(appleIdCredential: appleIDCredential)
//        let authCode: String = String(decoding: appleIDCredential.authorizationCode!, as: UTF8.self)
//        let idToken: String = String(decoding: appleIDCredential.identityToken!, as: UTF8.self)
//        print(authCode)
//        print(idToken)
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print(error.localizedDescription)
    }

    // MARK: Networking

    private func continueWithApple(appleIdCredential: ASAuthorizationAppleIDCredential) {
//        let userIdentifier = appleIdCredential.user
//        let fullName = appleIdCredential.fullName
//        let firstName = fullName?.givenName ?? ""
//        let lastName = fullName?.familyName ?? ""
//        let email = appleIdCredential.email
//
//        let request = ContinueWithAppleRequest(firstName: firstName, lastName: lastName, appleId: email, appleUserIdentifier: userIdentifier)
//
//        delegate?.authenticationDidBegin()
//
//        API.client().post(.apple, posting: request, expecting: AuthenticatedUserResponse.self, completion: { [weak self] (successState, response) in
//            switch successState {
//            case .success:
//                guard let response = response else {
//                    self?.delegate?.authenticationDidFail()
//                    ErrorManager.handleError(AuthenticationError.continueWithAppleFailed)
//                    return
//                }
//                self?.delegate?.authenticationDidSucceed(response: response)
//            case .failure(_, _):
//                ErrorManager.handleError(AuthenticationError.continueWithAppleFailed)
//            }
//        })
    }
}
