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
    case customError(String)
    
    var domain: BinkErrorDomain {
        return .userService
    }
    
    var errorCode: String? {
        return nil
    }
    
    var message: String {
        switch self {
        case .customError(let message):
            return message
        default: return ""
        }
    }
}

protocol UserServiceProtocol {}

extension UserServiceProtocol {
    func getUserProfile(completion: ServiceCompletionResultHandler<UserProfileResponse, UserServiceError>? = nil) {
        let request = BinkNetworkRequest(endpoint: .me, method: .get, headers: nil, isUserDriven: false)
        Current.apiClient.performRequest(request, expecting: UserProfileResponse.self) { (result, _) in
            switch result {
            case .success(let response):
                completion?(.success(response))
            case .failure:
                completion?(.failure(.failedToGetUserProfile))
            }
        }
    }
    
    func updateUserProfile(request: UserProfileUpdateRequest, completion: ServiceCompletionResultHandler<UserProfileResponse, UserServiceError>? = nil) {
        let networkRequest = BinkNetworkRequest(endpoint: .me, method: .put, headers: nil, isUserDriven: false)
        Current.apiClient.performRequestWithParameters(networkRequest, parameters: request, expecting: UserProfileResponse.self) { (result, _) in
            switch result {
            case .success(let response):
                completion?(.success(response))
            case .failure:
                completion?(.failure(.failedToGetUserProfile))
            }
        }
    }
    
    func logout(completion: ServiceCompletionResultHandler<LogoutResponse, UserServiceError>? = nil) {
        let request = BinkNetworkRequest(endpoint: .logout, method: .post, headers: nil, isUserDriven: false)
        Current.apiClient.performRequest(request, expecting: LogoutResponse.self) { (result, _) in
            switch result {
            case .success(let response):
                completion?(.success(response))
            case .failure:
                completion?(.failure(.failedToGetUserProfile))
            }
        }
    }
    
    func submitForgotPasswordRequest(forEmailAddress email: String, completion: ServiceCompletionSuccessHandler<UserServiceError>? = nil) {
        let request = BinkNetworkRequest(endpoint: .forgotPassword, method: .post, headers: nil, isUserDriven: true)
        Current.apiClient.performRequestWithNoResponse(request, parameters: ["email": email]) { (success, _) in
            guard success else {
                completion?(false, .failedToGetUserProfile)
                return
            }
            completion?(true, nil)
        }
    }
    
    func registerUser(request: LoginRegisterRequest, completion: ServiceCompletionResultHandler<LoginRegisterResponse, UserServiceError>? = nil) {
        let networtRequest = BinkNetworkRequest(endpoint: .register, method: .post, headers: nil, isUserDriven: true)
        Current.apiClient.performRequestWithParameters(networtRequest, parameters: request, expecting: LoginRegisterResponse.self) { (result, _) in
            switch result {
            case .success(let response):
                completion?(.success(response))
            case .failure:
                completion?(.failure(.failedToGetUserProfile))
            }
        }
    }
    
    func login(request: LoginRegisterRequest, completion: ServiceCompletionResultHandler<LoginRegisterResponse, UserServiceError>? = nil) {
        let networtRequest = BinkNetworkRequest(endpoint: .login, method: .post, headers: nil, isUserDriven: true)
        Current.apiClient.performRequestWithParameters(networtRequest, parameters: request, expecting: LoginRegisterResponse.self) { (result, _) in
            switch result {
            case .success(let response):
                completion?(.success(response))
            case .failure:
                completion?(.failure(.failedToGetUserProfile))
            }
        }
    }
    
    func authWithFacebook(request: FacebookRequest, completion: ServiceCompletionResultHandler<LoginRegisterResponse, UserServiceError>? = nil) {
        let networtRequest = BinkNetworkRequest(endpoint: .facebook, method: .post, headers: nil, isUserDriven: true)
        Current.apiClient.performRequestWithParameters(networtRequest, parameters: request, expecting: LoginRegisterResponse.self) { (result, _) in
            switch result {
            case .success(let response):
                completion?(.success(response))
            case .failure:
                completion?(.failure(.failedToGetUserProfile))
            }
        }
    }
    
    func authWithApple(request: SignInWithAppleRequest, completion: ServiceCompletionResultHandler<LoginRegisterResponse, UserServiceError>? = nil) {
        let networtRequest = BinkNetworkRequest(endpoint: .apple, method: .post, headers: nil, isUserDriven: true)
        Current.apiClient.performRequestWithParameters(networtRequest, parameters: request, expecting: LoginRegisterResponse.self) { (result, _) in
            switch result {
            case .success(let response):
                completion?(.success(response))
            case .failure:
                completion?(.failure(.failedToGetUserProfile))
            }
        }
    }
    
    func createService(params: [String: Any], completion: ServiceCompletionSuccessHandler<UserServiceError>? = nil) {
        let request = BinkNetworkRequest(endpoint: .service, method: .post, headers: nil, isUserDriven: false)
        Current.apiClient.performRequestWithNoResponse(request, parameters: params) { (success, _) in
            guard success else {
                completion?(false, .failedToGetUserProfile)
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
                completion?(.failure(.failedToGetUserProfile))
            }
        }
    }
    
    func setPreferences(params: [String: String], completion: ServiceCompletionSuccessHandler<UserServiceError>? = nil) {
        let request = BinkNetworkRequest(endpoint: .preferences, method: .put, headers: nil, isUserDriven: false)
        Current.apiClient.performRequestWithNoResponse(request, parameters: params) { (success, _) in
            guard success else {
                completion?(false, .failedToGetUserProfile)
                return
            }
            completion?(true, nil)
        }
    }
}
