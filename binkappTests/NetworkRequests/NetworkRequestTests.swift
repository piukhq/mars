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

class NetworkRequestTests: XCTestCase, UserServiceProtocol, WalletServiceProtocol, CoreDataTestable {
    static var logoutResponse: LogoutResponse!
    static var loginResponse: LoginResponse!
    static var baseFeatureSetModel: FeatureSetModel!
    static var baseMembershipPlanModel: MembershipPlanModel!
    static var baseMembershipCardModel: MembershipCardModel!
    static var basePaymentCardResponse: PaymentCardModel!
    static var paymentCardCardResponse: PaymentCardCardResponse!
    static let linkedResponse = LinkedCardResponse(id: 300, activeLink: true)
    static var membershipCard: CD_MembershipCard!
    static var paymentCard: CD_PaymentCard!
    override class func setUp() {
        logoutResponse = LogoutResponse(loggedOut: true)
        loginResponse = LoginResponse(apiKey: "apiKey", userEmail: "ricksanchez@email.com", uid: "turkey-chicken-beef", accessToken: "accessToken")
        
        baseFeatureSetModel = nil
        baseMembershipPlanModel = nil
        baseMembershipCardModel = nil
        
        baseFeatureSetModel = FeatureSetModel(apiId: nil, authorisationRequired: nil, transactionsAvailable: nil, digitalOnly: nil, hasPoints: true, cardType: .link, linkingSupport: nil, hasVouchers: nil)
        
        baseMembershipPlanModel = MembershipPlanModel(apiId: nil, status: nil, featureSet: baseFeatureSetModel, images: nil, account: nil, balances: nil, dynamicContent: nil, hasVouchers: nil, card: nil)
        
        baseMembershipCardModel = MembershipCardModel(apiId: 10, membershipPlan: 1, membershipTransactions: nil, status: MembershipCardStatusModel(apiId: nil, state: .authorised, reasonCodes: nil), card: nil, images: nil, account: nil, paymentCards: nil, balances: nil, vouchers: nil)
        
        paymentCardCardResponse = PaymentCardCardResponse(apiId: 100, firstSix: nil, lastFour: "1234", month: 30, year: 3000, country: nil, currencyCode: nil, nameOnCard: "Rick Sanchez", provider: nil, type: nil)
        
        basePaymentCardResponse = PaymentCardModel(apiId: 100, membershipCards: [Self.linkedResponse], status: "active", card: paymentCardCardResponse, account: PaymentCardAccountResponse(apiId: 0, verificationInProgress: nil, status: 0, consents: []))
        
        mapResponseToManagedObject(baseMembershipCardModel, managedObjectType: CD_MembershipCard.self) { membershipCard in
            self.membershipCard = membershipCard
        }
        
        mapResponseToManagedObject(Self.basePaymentCardResponse, managedObjectType: CD_PaymentCard.self) { paymentCard in
            Self.paymentCard = paymentCard
        }
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
        
        
        getMembershipPlans(isUserDriven: false) { result in
            switch result {
            case .success(let response):
                XCTAssertNotNil(response)
            case .failure:
                XCTFail()
            }
        }
        
        _ = XCTWaiter.wait(for: [self.expectation(description: "Wait for network call closure to complete")], timeout: 5.0)
    }
    
    func test_walletService_getMembershipCards() throws {
        Current.apiClient.testResponseData = nil
        let mocked = try! JSONEncoder().encode([Self.baseMembershipCardModel])
        
        let mock = Mock(url: URL(string: APIEndpoint.membershipCards.urlString!)!, dataType: .json, statusCode: 200, data: [.get: mocked])
        mock.register()
        
        
        getMembershipCards(isUserDriven: false) { result in
            switch result {
            case .success(let response):
                XCTAssertTrue(response[0].membershipPlan == 1)
            case .failure:
                XCTFail()
            }
        }
        
        _ = XCTWaiter.wait(for: [self.expectation(description: "Wait for network call closure to complete")], timeout: 5.0)
    }
    
    func test_walletService_addMembershipCard() throws {
        Current.apiClient.testResponseData = nil
        let model = MembershipCardPostModel(account: nil, membershipPlan: 1)
        let mocked = try! JSONEncoder().encode(Self.baseMembershipCardModel)

        let endpoint = APIEndpoint.membershipCard(cardId: Self.membershipCard.id).urlString!
        let mock = Mock(url: URL(string: endpoint)!, dataType: .json, statusCode: 200, data: [.put: mocked])
        mock.register()

        addMembershipCard(withRequestModel: model, existingMembershipCard: Self.membershipCard, completion: { result, e in
            switch result {
            case .success(let response):
                XCTAssertTrue(response.membershipPlan == 1)
            case .failure:
                XCTFail()
            }
        })

        _ = XCTWaiter.wait(for: [self.expectation(description: "Wait for network call closure to complete")], timeout: 5.0)
    }
    
    func test_walletService_addGhostCard() throws {
        Current.apiClient.testResponseData = nil
        let model = MembershipCardPostModel(account: nil, membershipPlan: 1)
        let mocked = try! JSONEncoder().encode(Self.baseMembershipCardModel)

        let endpoint = APIEndpoint.membershipCards.urlString!
        let mock = Mock(url: URL(string: endpoint)!, dataType: .json, statusCode: 200, data: [.post: mocked])
        mock.register()

        addGhostCard(withRequestModel: model, completion: { result in
            switch result {
            case .success(let response):
                XCTAssertTrue(response.membershipPlan == 1)
            case .failure:
                XCTFail()
            }
        })

        _ = XCTWaiter.wait(for: [self.expectation(description: "Wait for network call closure to complete")], timeout: 5.0)
    }
    
    func test_walletService_patchGhostCard() throws {
        Current.apiClient.testResponseData = nil
        let model = MembershipCardPostModel(account: nil, membershipPlan: 1)
        let mocked = try! JSONEncoder().encode(Self.baseMembershipCardModel)

        let endpoint = APIEndpoint.membershipCard(cardId: Self.membershipCard.id).urlString!
        let mock = Mock(url: URL(string: endpoint)!, dataType: .json, statusCode: 200, data: [.patch: mocked])
        mock.register()

        patchGhostCard(withRequestModel: model, existingMembershipCard: Self.membershipCard, completion: { result in
            switch result {
            case .success(let response):
                XCTAssertTrue(response.membershipPlan == 1)
            case .failure:
                XCTFail()
            }
        })

        _ = XCTWaiter.wait(for: [self.expectation(description: "Wait for network call closure to complete")], timeout: 5.0)
    }
    
    func test_walletService_deleteMembershipCard() throws {
        Current.apiClient.testResponseData = nil
        
        let endpoint = APIEndpoint.membershipCard(cardId: Self.membershipCard.id).urlString!
        let mock = Mock(url: URL(string: endpoint)!, dataType: .json, statusCode: 200, data: [.delete: Data()])
        mock.register()
        var completed = false
        
        deleteMembershipCard(Self.membershipCard, completion: { success, _, _ in
            completed = success
        })

        _ = XCTWaiter.wait(for: [self.expectation(description: "Wait for network call closure to complete")], timeout: 5.0)

        XCTAssertTrue(completed)
    }
    
    func test_walletService_getPaymentCards() throws {
        Current.apiClient.testResponseData = nil
        let mocked = try! JSONEncoder().encode([Self.basePaymentCardResponse])
        
        let mock = Mock(url: URL(string: APIEndpoint.paymentCards.urlString!)!, dataType: .json, statusCode: 200, data: [.get: mocked])
        mock.register()
        
        getPaymentCards(isUserDriven: false) { result in
            switch result {
            case .success(let response):
                XCTAssertTrue(response[0].apiId == 100)
                XCTAssertTrue(response[0].status == "active")
            case .failure:
                XCTFail()
            }
        }
        
        _ = XCTWaiter.wait(for: [self.expectation(description: "Wait for network call closure to complete")], timeout: 5.0)
    }
    
    func test_walletService_getSpreedlyToken() throws {
        Current.apiClient.testResponseData = nil
        let spreedlyRequest = SpreedlyRequest(fullName: "Rick", number: "200", month: 1, year: 2022)
        let spreedlyResponse = SpreedlyResponse(transaction: SpreedlyResponse.Transaction(paymentMethod: nil, state: "active", succeeded: true))
        
        let mocked = try! JSONEncoder().encode(spreedlyResponse)
        
        let mock = Mock(url: URL(string: APIEndpoint.spreedly.urlString!)!, dataType: .json, statusCode: 200, data: [.post: mocked])
        mock.register()
        
        getSpreedlyToken(withRequest: spreedlyRequest, completion: { result in
            switch result {
            case .success(let response):
                XCTAssertTrue(response.transaction!.state == "active")
            case .failure:
                XCTFail()
            }
        })
        
        _ = XCTWaiter.wait(for: [self.expectation(description: "Wait for network call closure to complete")], timeout: 5.0)
    }
    
//    func test_walletService_addPaymentCard() throws {
//        Current.apiClient.testResponseData = nil
//        let paymentCardCreateModel = PaymentCardCreateModel(fullPan: "5454 5454 5454 5454", nameOnCard: "Rick Morty", month: 4, year: 2030)
//
//        let cardRequest = PaymentCardCreateRequest(model: paymentCardCreateModel)
//
//        let mocked = try! JSONEncoder().encode(Self.basePaymentCardResponse)
//
//        let mock = Mock(url: URL(string: APIEndpoint.paymentCards.urlString!)!, dataType: .json, statusCode: 200, data: [.post: mocked])
//        mock.register()
//
//        addPaymentCard(withRequestModel: cardRequest!, completion: { result, e in
//            switch result {
//            case .success(let response):
//                XCTAssertTrue(response.apiId == 100)
//            case .failure:
//                XCTFail()
//            }
//        })
//
//        _ = XCTWaiter.wait(for: [self.expectation(description: "Wait for network call closure to complete")], timeout: 5.0)
//    }
    
    func test_walletService_deletePaymentCard() throws {
        Current.apiClient.testResponseData = nil
        
        let endpoint = APIEndpoint.paymentCard(cardId: Self.paymentCard.id).urlString!
        let mock = Mock(url: URL(string: endpoint)!, dataType: .json, statusCode: 200, data: [.delete: Data()])
        mock.register()
        var completed = false
        
        deletePaymentCard(Self.paymentCard, completion: { success, _, _ in
            completed = success
        })

        _ = XCTWaiter.wait(for: [self.expectation(description: "Wait for network call closure to complete")], timeout: 5.0)

        XCTAssertTrue(completed)
    }
    
    func test_walletService_toggleMembershipCardPaymentCardLink_ShouldLink() throws {
        Current.apiClient.testResponseData = nil
        
        let mocked = try! JSONEncoder().encode(Self.basePaymentCardResponse)
        let endpoint = APIEndpoint.linkMembershipCardToPaymentCard(membershipCardId: Self.membershipCard.id, paymentCardId: Self.paymentCard.id).urlString!
        let mock = Mock(url: URL(string: endpoint)!, dataType: .json, statusCode: 200, data: [.patch: mocked])
        mock.register()
        
        toggleMembershipCardPaymentCardLink(membershipCard: Self.membershipCard, paymentCard: Self.paymentCard, shouldLink: true, completion: { result in
            switch result {
            case .success(let response):
                XCTAssertTrue(response.apiId == 100)
                XCTAssertTrue(response.status == "active")
            case .failure:
                XCTFail()
            }
        })

        _ = XCTWaiter.wait(for: [self.expectation(description: "Wait for network call closure to complete")], timeout: 5.0)
    }
    
    func test_walletService_toggleMembershipCardPaymentCardLink_Should_Not_Link() throws {
        Current.apiClient.testResponseData = nil
        
        let mocked = try! JSONEncoder().encode(Self.basePaymentCardResponse)
        let endpoint = APIEndpoint.linkMembershipCardToPaymentCard(membershipCardId: Self.membershipCard.id, paymentCardId: Self.paymentCard.id).urlString!
        let mock = Mock(url: URL(string: endpoint)!, dataType: .json, statusCode: 200, data: [.delete: mocked])
        mock.register()
        
        toggleMembershipCardPaymentCardLink(membershipCard: Self.membershipCard, paymentCard: Self.paymentCard, shouldLink: false, completion: { result in
            switch result {
            case .success(let response):
                XCTAssertTrue(response.apiId == 100)
                XCTAssertTrue(response.status == "active")
            case .failure:
                XCTFail()
            }
        })

        _ = XCTWaiter.wait(for: [self.expectation(description: "Wait for network call closure to complete")], timeout: 5.0)
    }
    
    // MARK: network errors
    func test_networkErrors_TextIsCorrect() throws {
        var error = NetworkingError.invalidRequest
        XCTAssertTrue(error.domain == .networking)
        XCTAssertTrue(error.message == "Invalid request")
        
        error = NetworkingError.unauthorized
        XCTAssertTrue(error.message == "Request unauthorized")
        
        error = NetworkingError.noInternetConnection
        XCTAssertTrue(error.message == "No internet connection")
        
        error = NetworkingError.methodNotAllowed
        XCTAssertTrue(error.message == "Method not allowed")
        
        error = NetworkingError.invalidUrl
        XCTAssertTrue(error.message == "Invalid URL")
        
        error = NetworkingError.sslPinningFailure
        XCTAssertTrue(error.message == "SSL pinning failure")
        
        error = NetworkingError.invalidResponse
        XCTAssertTrue(error.message == "Invalid response")
        
        error = NetworkingError.decodingError
        XCTAssertTrue(error.message == "Decoding error")
        
        error = NetworkingError.clientError(500)
        XCTAssertTrue(error.message == "Client error with status code 500")
        
        error = NetworkingError.checkStatusCode(400)
        XCTAssertTrue(error.message == "Error with status code 400")
        
        error = NetworkingError.customError("Custom error")
        XCTAssertTrue(error.message == "Custom error")
        
        error = NetworkingError.userFacingError(UserFacingNetworkingError.planAlreadyLinked)
        XCTAssertTrue(error.message == "PLAN_ALREADY_LINKED")
    }
}
