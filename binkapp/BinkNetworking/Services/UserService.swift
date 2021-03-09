//
//  UserService.swift
//  binkapp
//
//  Created by Nick Farrant on 13/08/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import Foundation
import Alamofire

enum UserServiceError: BinkError {
    case failedToGetUserProfile
    case failedToUpdateUserProfile
    case failedToLogout
    case failedToSubmitForgotPasswordRequest
    case failedToRegisterUser
    case failedToLogin
    case failedToAuthWithFacebook
    case failedToAuthWithApple
    case failedToCreateService
    case failedToGetPreferences
    case failedToSetPreferences
    case failedToRenewToken
    case customError(String)
    
    var domain: BinkErrorDomain {
        return .userService
    }
    
    var errorCode: String? {
        return nil
    }
    
    var message: String {
        switch self {
        case .failedToGetUserProfile:
            return "Failed to get user profile"
        case .failedToUpdateUserProfile:
            return "Failed to update user profile"
        case .failedToLogout:
            return "Failed to logout"
        case .failedToSubmitForgotPasswordRequest:
            return "Failed to submit forgot password request"
        case .failedToRegisterUser:
            return "Failed to register user"
        case .failedToLogin:
            return "Failed to login"
        case .failedToAuthWithFacebook:
            return "Failed to auth with facebook"
        case .failedToAuthWithApple:
            return "Failed to auth with apple"
        case .failedToCreateService:
            return "Failed to create service"
        case .failedToGetPreferences:
            return "Failed to get preferences"
        case .failedToSetPreferences:
            return "Failed to set preferences"
        case .failedToRenewToken:
            return "Failed to renew token"
        case .customError(let message):
            return message
        }
    }
}

protocol UserServiceProtocol {}

extension UserServiceProtocol {
    func getUserProfile(completion: ServiceCompletionResultHandler<UserProfileResponse, UserServiceError>? = nil) {
        let request = BinkNetworkRequest(endpoint: .me, method: .get, headers: nil, isUserDriven: false)
        Current.apiClient.performRequest(request, expecting: UserProfileResponse.self) { (result, rawResponse) in
            switch result {
            case .success(let response):
                if #available(iOS 14.0, *) {
                    BinkLogger.infoPrivateHash(.getUserProfile, value: response.uid, category: .userServiceProtocol)
                }
                completion?(.success(response))
            case .failure:
                if #available(iOS 14.0, *) {
                    BinkLogger.error(.getUserProfile, value: rawResponse?.urlResponse?.statusCode.description, category: .userServiceProtocol)
                }
                completion?(.failure(.failedToGetUserProfile))
            }
        }
    }
    
    func updateUserProfile(request: UserProfileUpdateRequest, completion: ServiceCompletionResultHandler<UserProfileResponse, UserServiceError>? = nil) {
        let networkRequest = BinkNetworkRequest(endpoint: .me, method: .put, headers: nil, isUserDriven: false)
        Current.apiClient.performRequestWithBody(networkRequest, body: request, expecting: UserProfileResponse.self) { (result, rawResponse) in
            switch result {
            case .success(let response):
                if #available(iOS 14.0, *) {
                    BinkLogger.infoPrivateHash(.updatedUserProfile, value: response.uid, category: .userServiceProtocol)
                }
                completion?(.success(response))
            case .failure:
                if #available(iOS 14.0, *) {
                    BinkLogger.error(.updateUserProfileFailure, value: rawResponse?.urlResponse?.statusCode.description, category: .userServiceProtocol)
                }
                completion?(.failure(.failedToUpdateUserProfile))
            }
        }
    }
    
    func logout(completion: ServiceCompletionResultHandler<LogoutResponse, UserServiceError>? = nil) {
        let request = BinkNetworkRequest(endpoint: .logout, method: .post, headers: nil, isUserDriven: false)
        Current.apiClient.performRequest(request, expecting: LogoutResponse.self) { (result, rawResponse) in
            switch result {
            case .success(let response):
                if #available(iOS 14.0, *) {
                    BinkLogger.info(.logout, value: nil, category: .userServiceProtocol)
                }
                completion?(.success(response))
            case .failure:
                if #available(iOS 14.0, *) {
                    BinkLogger.error(.userLogoutFailure, value: rawResponse?.urlResponse?.statusCode.description, category: .userServiceProtocol)
                }
                completion?(.failure(.failedToLogout))
            }
        }
    }
    
    func submitForgotPasswordRequest(forEmailAddress email: String, completion: ServiceCompletionSuccessHandler<UserServiceError>? = nil) {
        let request = BinkNetworkRequest(endpoint: .forgotPassword, method: .post, headers: nil, isUserDriven: true)
        Current.apiClient.performRequestWithNoResponse(request, body: ["email": email]) { (success, _, rawResponse) in
            guard success else {
                if #available(iOS 14.0, *) {
                    BinkLogger.error(.forgotPasswordRequestFailure, value: rawResponse?.urlResponse?.statusCode.description, category: .userServiceProtocol)
                }
                completion?(false, .failedToSubmitForgotPasswordRequest)
                return
            }
            if #available(iOS 14.0, *) {
                BinkLogger.infoPrivateHash(.submittedForgotPasswordRequest, value: email, category: .userServiceProtocol)
            }
            completion?(true, nil)
        }
    }
    
    func registerUser(request: LoginRegisterRequest, completion: ServiceCompletionResultHandler<LoginRegisterResponse, UserServiceError>? = nil) {
        let networtRequest = BinkNetworkRequest(endpoint: .register, method: .post, headers: nil, isUserDriven: true)
        Current.apiClient.performRequestWithBody(networtRequest, body: request, expecting: LoginRegisterResponse.self) { (result, rawResponse) in
            switch result {
            case .success(let response):
                if #available(iOS 14.0, *) {
                    BinkLogger.infoPrivateHash(.registeredUser, value: response.uid, category: .userServiceProtocol)
                }
                completion?(.success(response))
            case .failure:
                if #available(iOS 14.0, *) {
                    BinkLogger.error(.userRegistrationFailure, value: rawResponse?.urlResponse?.statusCode.description, category: .userServiceProtocol)
                }
                completion?(.failure(.failedToRegisterUser))
            }
        }
    }
    
    func login(request: LoginRegisterRequest, completion: ServiceCompletionResultHandler<LoginRegisterResponse, UserServiceError>? = nil) {
        let networtRequest = BinkNetworkRequest(endpoint: .login, method: .post, headers: nil, isUserDriven: true)
        Current.apiClient.performRequestWithBody(networtRequest, body: request, expecting: LoginRegisterResponse.self) { (result, rawResponse) in
            switch result {
            case .success(let response):
                if #available(iOS 14.0, *) {
                    BinkLogger.infoPrivateHash(.userLoggedIn, value: response.uid, category: .userServiceProtocol)
                }
                completion?(.success(response))
            case .failure:
                if #available(iOS 14.0, *) {
                    BinkLogger.error(.userLoginFailure, value: rawResponse?.urlResponse?.statusCode.description, category: .userServiceProtocol)
                }
                completion?(.failure(.failedToLogin))
            }
        }
    }
    
    func authWithFacebook(request: FacebookRequest, completion: ServiceCompletionResultHandler<LoginRegisterResponse, UserServiceError>? = nil) {
        let networtRequest = BinkNetworkRequest(endpoint: .facebook, method: .post, headers: nil, isUserDriven: true)
        Current.apiClient.performRequestWithBody(networtRequest, body: request, expecting: LoginRegisterResponse.self) { (result, _) in
            switch result {
            case .success(let response):
                completion?(.success(response))
            case .failure:
                completion?(.failure(.failedToAuthWithFacebook))
            }
        }
    }
    
    func authWithApple(request: SignInWithAppleRequest, completion: ServiceCompletionResultHandler<LoginRegisterResponse, UserServiceError>? = nil) {
        let networtRequest = BinkNetworkRequest(endpoint: .apple, method: .post, headers: nil, isUserDriven: true)
        Current.apiClient.performRequestWithBody(networtRequest, body: request, expecting: LoginRegisterResponse.self) { (result, _) in
            switch result {
            case .success(let response):
                completion?(.success(response))
            case .failure:
                completion?(.failure(.failedToAuthWithApple))
            }
        }
    }
    
    func createService(params: [String: Any], completion: ServiceCompletionSuccessHandler<UserServiceError>? = nil) {
        let request = BinkNetworkRequest(endpoint: .service, method: .post, headers: nil, isUserDriven: false)
        Current.apiClient.performRequestWithNoResponse(request, body: params) { (success, _, _) in
            guard success else {
                completion?(false, .failedToCreateService)
                return
            }
            completion?(true, nil)
        }
    }
    
    func getPreferences(completion: ServiceCompletionResultHandler<[PreferencesModel], UserServiceError>? = nil) {
        let request = BinkNetworkRequest(endpoint: .preferences, method: .get, headers: nil, isUserDriven: false)
        Current.apiClient.performRequest(request, expecting: [PreferencesModel].self) { (result, _) in
            switch result {
            case .success(let response):
                completion?(.success(response))
            case .failure:
                completion?(.failure(.failedToGetPreferences))
            }
        }
    }
    
    func setPreferences(params: [String: String], completion: ServiceCompletionSuccessHandler<UserServiceError>? = nil) {
        let request = BinkNetworkRequest(endpoint: .preferences, method: .put, headers: nil, isUserDriven: false)
        Current.apiClient.performRequestWithNoResponse(request, body: params) { (success, _, _) in
            guard success else {
                completion?(false, .failedToSetPreferences)
                return
            }
            completion?(true, nil)
        }
    }
    
    func renewToken(_ currentToken: String, completion: ServiceCompletionResultHandler<RenewTokenResponse, UserServiceError>? = nil) {
        let request = BinkNetworkRequest(endpoint: .renew, method: .post, headers: [.authorization(currentToken), .defaultContentType, .acceptWithAPIVersion()], isUserDriven: false)
        Current.apiClient.performRequest(request, expecting: RenewTokenResponse.self) { (result, _) in
            switch result {
            case .success(let response):
                completion?(.success(response))
            case .failure:
                completion?(.failure(.failedToRenewToken))
            }
        }
    }
}
