//
//  NetworkRequestTests.swift
//  binkappTests
//
//  Created by Ricardo Silva on 19/08/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import XCTest
import Mocker
@testable import binkapp

// swiftlint:disable all

class NetworkRequestTests: XCTestCase, UserServiceProtocol, WalletServiceProtocol {
    static var logoutResponse: LogoutResponse!
    static var loginResponse: LoginResponse!
    static var baseFeatureSetModel: FeatureSetModel!
    static var baseMembershipPlanModel: MembershipPlanModel!
    static var baseMembershipCardModel: MembershipCardModel!
    override class func setUp() {
        logoutResponse = LogoutResponse(loggedOut: true)
        loginResponse = LoginResponse(apiKey: "apiKey", userEmail: "ricksanchez@email.com", uid: "turkey-chicken-beef", accessToken: "accessToken")
        
        baseFeatureSetModel = nil
        baseMembershipPlanModel = nil
        baseMembershipCardModel = nil
        
        baseFeatureSetModel = FeatureSetModel(apiId: nil, authorisationRequired: nil, transactionsAvailable: nil, digitalOnly: nil, hasPoints: true, cardType: .link, linkingSupport: nil, hasVouchers: nil)
        
        baseMembershipPlanModel = MembershipPlanModel(apiId: nil, status: nil, featureSet: baseFeatureSetModel, images: nil, account: nil, balances: nil, dynamicContent: nil, hasVouchers: nil, card: nil)
        
        baseMembershipCardModel = MembershipCardModel(apiId: nil, membershipPlan: 1, membershipTransactions: nil, status: MembershipCardStatusModel(apiId: nil, state: .authorised, reasonCodes: nil), card: nil, images: nil, account: nil, paymentCards: nil, balances: nil, vouchers: nil)
    }
    
    func test_login() throws {
        Current.apiClient.testResponseData = nil
        let loginRequest = LoginRequest(email: "ricksanchez@email.com", password: "testpass")
        
        let mocked = try! JSONEncoder().encode(Self.loginResponse)
        let mock = Mock(url: URL(string: APIEndpoint.login.urlString!)!, dataType: .json, statusCode: 200, data: [.post: mocked])
        mock.register()
        
//        let mockService = Mock(url: URL(string: APIEndpoint.service.urlString!)!, dataType: .json, statusCode: 200, data: [.post: Data()])
//        mockService.register()
        
        login(request: loginRequest) {result in
            switch result {
            case .success(let response):
                XCTAssertEqual(response.apiKey, "apiKey")
                XCTAssertEqual(response.userEmail, "ricksanchez@email.com")
                XCTAssertEqual(response.uid, "turkey-chicken-beef")
            case .failure:
                XCTFail()
            }
        }
        
//        Current.loginController.login(with: loginRequest) { error in
//            if error != nil {
//                print("all good")
//            }
//        }
        
        _ = XCTWaiter.wait(for: [self.expectation(description: "Wait for network call closure to complete")], timeout: 5.0)
        
        //XCTAssertNotNil(Current.apiClient.testResponseData)
    }
    
    func test_loginWithApple() throws {
        Current.apiClient.testResponseData = nil
        let appleLoginRequest = SignInWithAppleRequest(authorizationCode: "code")
        let mocked = try! JSONEncoder().encode(Self.loginResponse)
        let mock = Mock(url: URL(string: APIEndpoint.apple.urlString!)!, dataType: .json, statusCode: 200, data: [.post: mocked])
        mock.register()
        
        authWithApple(request: appleLoginRequest) {result in
            switch result {
            case .success(let response):
                XCTAssertEqual(response.apiKey, "apiKey")
                XCTAssertEqual(response.userEmail, "ricksanchez@email.com")
                XCTAssertEqual(response.uid, "turkey-chicken-beef")
            case .failure:
                XCTFail()
            }
        }
        
        _ = XCTWaiter.wait(for: [self.expectation(description: "Wait for network call closure to complete")], timeout: 5.0)
    }
    
    func test_renewToken() throws {
        let currentToken = "pizza"
        let mocked = try! JSONEncoder().encode(Self.loginResponse)
        let mock = Mock(url: URL(string: APIEndpoint.renew.urlString!)!, dataType: .json, statusCode: 200, data: [.post: mocked])
        mock.register()
        
        renewToken(currentToken) { result in
            switch result {
            case .success(let response):
                XCTAssertEqual(response.accessToken, "accessToken")
            case .failure:
                XCTFail()
            }
        }
        
        _ = XCTWaiter.wait(for: [self.expectation(description: "Wait for network call closure to complete")], timeout: 5.0)
    }
    
    func test_userProfile() throws {
        let userProfileResponse = UserProfileResponse(uid: "turkey-chicken-beef", firstName: "Rick", lastName: "Morty", email: "ricksanchez@email.com")
        let mocked = try! JSONEncoder().encode(userProfileResponse)
        let mock = Mock(url: URL(string: APIEndpoint.me.urlString!)!, dataType: .json, statusCode: 200, data: [.get: mocked])
        mock.register()
        
        getUserProfile { result in
            switch result {
            case .success(let response):
                XCTAssertEqual(response.uid, "turkey-chicken-beef")
                XCTAssertEqual(response.email, "ricksanchez@email.com")
            case .failure:
                XCTFail()
            }
        }
                       
        _ = XCTWaiter.wait(for: [self.expectation(description: "Wait for network call closure to complete")], timeout: 5.0)
    }
    
    func test_updateUserProfile() throws {
        let userProfileUpdateRequest = UserProfileUpdateRequest(firstName: "James", lastName: "Hetfield")
        let userProfileResponse = UserProfileResponse(uid: "turkey-chicken-beef", firstName: "James", lastName: "Hetfield", email: "ricksanchez@email.com")
        let mocked = try! JSONEncoder().encode(userProfileResponse)
        let mock = Mock(url: URL(string: APIEndpoint.me.urlString!)!, dataType: .json, statusCode: 200, data: [.put: mocked])
        mock.register()
        
        updateUserProfile(request: userProfileUpdateRequest, completion: { result in
            switch result {
            case .success(let response):
                XCTAssertEqual(response.firstName, "James")
                XCTAssertEqual(response.lastName, "Hetfield")
            case .failure:
                XCTFail()
            }
        })
        
        _ = XCTWaiter.wait(for: [self.expectation(description: "Wait for network call closure to complete")], timeout: 5.0)
    }
    
    func test_registerUser() throws {
        let loginRequest = LoginRequest(email: "ricksanchez@email.com", password: "testpass")
        let mocked = try! JSONEncoder().encode(Self.loginResponse)
        let mock = Mock(url: URL(string: APIEndpoint.register.urlString!)!, dataType: .json, statusCode: 200, data: [.post: mocked])
        mock.register()
        
        registerUser(request: loginRequest, completion: { result in
            switch result {
            case .success(let response):
                XCTAssertEqual(response.apiKey, "apiKey")
                XCTAssertEqual(response.userEmail, "ricksanchez@email.com")
                XCTAssertEqual(response.uid, "turkey-chicken-beef")
            case .failure:
                XCTFail()
            }
        })
        
        _ = XCTWaiter.wait(for: [self.expectation(description: "Wait for network call closure to complete")], timeout: 5.0)
    }
    
    func test_networkLogout() throws {
        Current.apiClient.testResponseData = nil
        let mocked = try! JSONEncoder().encode(Self.logoutResponse)
        let mock = Mock(url: URL(string: APIEndpoint.logout.urlString!)!, dataType: .json, statusCode: 200, data: [.post: mocked])
        mock.register()

        Current.rootStateMachine.handleLogout()

        _ = XCTWaiter.wait(for: [self.expectation(description: "Wait for network call closure to complete")], timeout: 5.0)

        XCTAssertNotNil(Current.apiClient.testResponseData)
    }
    
    func test_network_requestMagicLink() throws {
        Current.apiClient.testResponseData = nil
        let mock = Mock(url: URL(string: APIEndpoint.magicLinks.urlString!)!, dataType: .json, statusCode: 200, data: [.post: Data()])
        mock.register()
        var completed = false
        Current.rootStateMachine.requestMagicLink(email: "butters.is.grounded@gmail.com") { (success, _) in
            completed = success
        }

        _ = XCTWaiter.wait(for: [self.expectation(description: "Wait for network call closure to complete")], timeout: 5.0)

        XCTAssertTrue(completed)
    }
    
    func test_requestMagicLinkAccessToken() throws {
        let mocked = try! JSONEncoder().encode(Self.loginResponse)
        let mock = Mock(url: URL(string: APIEndpoint.magicLinksAccessTokens.urlString!)!, dataType: .json, statusCode: 200, data: [.post: mocked])
        mock.register()
        
        requestMagicLinkAccessToken(for: "accessToken", completion: { result, res  in
            switch result {
            case .success(let response):
                XCTAssertEqual(response.accessToken, "accessToken")
            case .failure:
                XCTFail()
            }
        })
        
        _ = XCTWaiter.wait(for: [self.expectation(description: "Wait for network call closure to complete")], timeout: 5.0)
    }
    
    func test_network_requestForgotPassword() throws {
        Current.apiClient.testResponseData = nil
        let mock = Mock(url: URL(string: APIEndpoint.forgotPassword.urlString!)!, dataType: .json, statusCode: 200, data: [.post: Data()])
        mock.register()
        var completed = false
        Current.rootStateMachine.submitForgotPasswordRequest(forEmailAddress: "something@mail.com") { (success, _) in
            completed = success
        }

        _ = XCTWaiter.wait(for: [self.expectation(description: "Wait for network call closure to complete")], timeout: 5.0)

        XCTAssertTrue(completed)
    }
    
    func test_preferences() throws {
        Current.apiClient.testResponseData = nil
        let preferencesModel = [PreferencesModel(isUserDefined: true, user: 1, value: "0", slug: "marketing", defaultValue: "0", valueType: "boolean", scheme: nil, label: "Marketing Bink", category: "marketing")]
        let mocked = try! JSONEncoder().encode(preferencesModel)
        
        let mock = Mock(url: URL(string: APIEndpoint.preferences.urlString!)!, dataType: .json, statusCode: 200, data: [.get: mocked])
        mock.register()
        
        getPreferences(completion: { result in
            switch result {
            case .success(let response):
                let safeResponse = response.compactMap { $0.value }
                XCTAssertNotNil(safeResponse)
            case .failure:
                XCTFail()
            }
        })
        
        _ = XCTWaiter.wait(for: [self.expectation(description: "Wait for network call closure to complete")], timeout: 5.0)
    }
    
    
    // WALLET SERVICE
    
    func test_walletService_getMembershipPlans() throws {
        Current.apiClient.testResponseData = nil
        let mocked = try! JSONEncoder().encode([Self.baseMembershipPlanModel])
        
        let mock = Mock(url: URL(string: APIEndpoint.membershipPlans.urlString!)!, dataType: .json, statusCode: 200, data: [.get: mocked])
        mock.register()
        
        
        getMembershipPlans(isUserDriven: false) { [weak self] result in
        }
    }
}
