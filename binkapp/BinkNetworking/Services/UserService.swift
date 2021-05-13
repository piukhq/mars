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
        Current.apiClient.performRequest(request, expecting: Safe<UserProfileResponse>.self) { (result, rawResponse) in
            switch result {
            case .success(let response):
                if #available(iOS 14.0, *) {
                    BinkLogger.infoPrivateHash(event: UserLoggerEvent.fetchedUserProfile, value: response.value?.uid ?? "")
                }
                guard let safeResponse = response.value else {
                    completion?(.failure(.customError("Failed to decode user profile response")))
                    return
                }
                completion?(.success(safeResponse))
            case .failure:
                if #available(iOS 14.0, *) {
                    BinkLogger.error(UserLoggerError.fetchUserProfile, value: rawResponse?.urlResponse?.statusCode.description)
                }
                completion?(.failure(.failedToGetUserProfile))
            }
        }
    }
    
    func updateUserProfile(request: UserProfileUpdateRequest, completion: ServiceCompletionResultHandler<UserProfileResponse, UserServiceError>? = nil) {
        let networkRequest = BinkNetworkRequest(endpoint: .me, method: .put, headers: nil, isUserDriven: false)
        Current.apiClient.performRequestWithBody(networkRequest, body: request, expecting: Safe<UserProfileResponse>.self) { (result, rawResponse) in
            switch result {
            case .success(let response):
                if #available(iOS 14.0, *) {
                    BinkLogger.infoPrivateHash(event: UserLoggerEvent.updatedUserProfile, value: response.value?.uid ?? "")
                }
                guard let safeResponse = response.value else {
                    completion?(.failure(.customError("Failed to decode user profile response")))
                    return
                }
                completion?(.success(safeResponse))
            case .failure:
                if #available(iOS 14.0, *) {
                    BinkLogger.error(UserLoggerError.updateUserProfileFailure, value: rawResponse?.urlResponse?.statusCode.description)
                }
                completion?(.failure(.failedToUpdateUserProfile))
            }
        }
    }
    
    func logout(completion: ServiceCompletionResultHandler<LogoutResponse, UserServiceError>? = nil) {
        let request = BinkNetworkRequest(endpoint: .logout, method: .post, headers: nil, isUserDriven: false)
        Current.apiClient.performRequest(request, expecting: Safe<LogoutResponse>.self) { (result, rawResponse) in
            switch result {
            case .success(let response):
                if #available(iOS 14.0, *) {
                    BinkLogger.info(event: UserLoggerEvent.logout)
                }
                guard let safeResponse = response.value else {
                    completion?(.failure(.customError("Failed to decode logout response")))
                    return
                }
                completion?(.success(safeResponse))
            case .failure:
                if #available(iOS 14.0, *) {
                    BinkLogger.error(UserLoggerError.userLogoutFailure, value: rawResponse?.urlResponse?.statusCode.description)
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
                    BinkLogger.error(UserLoggerError.forgotPasswordRequestFailure, value: rawResponse?.urlResponse?.statusCode.description)
                }
                completion?(false, .failedToSubmitForgotPasswordRequest)
                return
            }
            if #available(iOS 14.0, *) {
                BinkLogger.infoPrivateHash(event: UserLoggerEvent.submittedForgotPasswordRequest, value: email)
            }
            completion?(true, nil)
        }
    }

    func registerUser(request: LoginRegisterRequest, completion: ServiceCompletionResultHandler<LoginRegisterResponse, UserServiceError>? = nil) {
        let networtRequest = BinkNetworkRequest(endpoint: .register, method: .post, headers: nil, isUserDriven: true)
        Current.apiClient.performRequestWithBody(networtRequest, body: request, expecting: Safe<LoginRegisterResponse>.self) { (result, rawResponse) in
            switch result {
            case .success(let response):
                if #available(iOS 14.0, *) {
                    BinkLogger.infoPrivateHash(event: UserLoggerEvent.registeredUser, value: response.value?.uid ?? "")
                }
                guard let safeResponse = response.value else {
                    completion?(.failure(.customError("Failed to decode register response")))
                    return
                }
                completion?(.success(safeResponse))
            case .failure:
                if #available(iOS 14.0, *) {
                    BinkLogger.error(UserLoggerError.userRegistrationFailure, value: rawResponse?.urlResponse?.statusCode.description)
                }
                completion?(.failure(.failedToRegisterUser))
            }
        }
    }
    
    func login(request: LoginRegisterRequest, completion: ServiceCompletionResultHandler<LoginRegisterResponse, UserServiceError>? = nil) {
        let networtRequest = BinkNetworkRequest(endpoint: .login, method: .post, headers: nil, isUserDriven: true)
        Current.apiClient.performRequestWithBody(networtRequest, body: request, expecting: Safe<LoginRegisterResponse>.self) { (result, rawResponse) in
            switch result {
            case .success(let response):
                if #available(iOS 14.0, *) {
                    BinkLogger.infoPrivateHash(event: UserLoggerEvent.userLoggedIn, value: response.value?.uid ?? "")
                }
                guard let safeResponse = response.value else {
                    completion?(.failure(.customError("Failed to decode login response")))
                    return
                }
                completion?(.success(safeResponse))
            case .failure:
                if #available(iOS 14.0, *) {
                    BinkLogger.error(UserLoggerError.userLoginFailure, value: rawResponse?.urlResponse?.statusCode.description)
                }
                completion?(.failure(.failedToLogin))
            }
        }
    }
    
    func authWithApple(request: SignInWithAppleRequest, completion: ServiceCompletionResultHandler<LoginRegisterResponse, UserServiceError>? = nil) {
        let networtRequest = BinkNetworkRequest(endpoint: .apple, method: .post, headers: nil, isUserDriven: true)
        Current.apiClient.performRequestWithBody(networtRequest, body: request, expecting: Safe<LoginRegisterResponse>.self) { (result, _) in
            switch result {
            case .success(let response):
                if #available(iOS 14.0, *) {
                    BinkLogger.infoPrivateHash(event: UserLoggerEvent.signedInWithApple, value: response.value?.uid ?? "")
                }
                guard let safeResponse = response.value else {
                    completion?(.failure(.customError("Failed to decode apple auth response")))
                    return
                }
                completion?(.success(safeResponse))
            case .failure:
                completion?(.failure(.failedToAuthWithApple))
            }
        }
    }
    
    func createService(params: [String: Any], completion: ServiceCompletionSuccessHandler<UserServiceError>? = nil) {
        let request = BinkNetworkRequest(endpoint: .service, method: .post, headers: nil, isUserDriven: false)
        Current.apiClient.performRequestWithNoResponse(request, body: params) { (success, _, rawResponse) in
            guard success else {
                if #available(iOS 14.0, *) {
                    BinkLogger.error(UserLoggerError.createServiceFailure, value: rawResponse?.urlResponse?.statusCode.description)
                }
                completion?(false, .failedToCreateService)
                return
            }
            if #available(iOS 14.0, *) {
                BinkLogger.info(event: UserLoggerEvent.createdService)
            }
            completion?(true, nil)
        }
    }
    
    func getPreferences(completion: ServiceCompletionResultHandler<[PreferencesModel], UserServiceError>? = nil) {
        let request = BinkNetworkRequest(endpoint: .preferences, method: .get, headers: nil, isUserDriven: false)
        Current.apiClient.performRequest(request, expecting: [Safe<PreferencesModel>].self) { (result, rawResponse) in
            switch result {
            case .success(let response):
                if #available(iOS 14.0, *) {
                    BinkLogger.info(event: UserLoggerEvent.fetchedPreferences)
                }
                let safeResponse = response.compactMap { $0.value }
                completion?(.success(safeResponse))
            case .failure:
                if #available(iOS 14.0, *) {
                    BinkLogger.error(UserLoggerError.fetchPreferencesFailure, value: rawResponse?.urlResponse?.statusCode.description)
                }
                completion?(.failure(.failedToGetPreferences))
            }
        }
    }
    
    func setPreferences(params: [String: String], completion: ServiceCompletionSuccessHandler<UserServiceError>? = nil) {
        let request = BinkNetworkRequest(endpoint: .preferences, method: .put, headers: nil, isUserDriven: false)
        Current.apiClient.performRequestWithNoResponse(request, body: params) { (success, _, rawResponse) in
            guard success else {
                if #available(iOS 14.0, *) {
                    BinkLogger.error(UserLoggerError.setPreferencesFailure, value: rawResponse?.urlResponse?.statusCode.description)
                }
                completion?(false, .failedToSetPreferences)
                return
            }
            if #available(iOS 14.0, *) {
                BinkLogger.info(event: UserLoggerEvent.setPreferences)
            }
            completion?(true, nil)
        }
    }
    
    func renewToken(_ currentToken: String, completion: ServiceCompletionResultHandler<RenewTokenResponse, UserServiceError>? = nil) {
        let request = BinkNetworkRequest(endpoint: .renew, method: .post, headers: [.authorization(currentToken), .defaultContentType, .acceptWithAPIVersion()], isUserDriven: false)
        Current.apiClient.performRequest(request, expecting: Safe<RenewTokenResponse>.self) { (result, rawResponse) in
            switch result {
            case .success(let response):
                if #available(iOS 14.0, *) {
                    BinkLogger.infoPrivateHash(event: UserLoggerEvent.renewedToken, value: response.value?.apiKey ?? "")
                }
                guard let safeResponse = response.value else {
                    completion?(.failure(.customError("Failed to decode renew token response")))
                    return
                }
                completion?(.success(safeResponse))
            case .failure:
                if #available(iOS 14.0, *) {
                    BinkLogger.error(UserLoggerError.renewTokenFailure, value: rawResponse?.urlResponse?.statusCode.description)
                }
                completion?(.failure(.failedToRenewToken))
            }
        }
    }
}
