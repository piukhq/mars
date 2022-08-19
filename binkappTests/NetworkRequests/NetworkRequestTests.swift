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

class NetworkRequestTests: XCTestCase {
    static var logoutResponse: LogoutResponse!
    override class func setUp() {
        logoutResponse = LogoutResponse(loggedOut: true)
    }
    
//    func test_network_me() throws {
//        Current.apiClient.testResponseData = nil
//        let mocked = try! JSONEncoder().encode(Self.logoutResponse)
//        let mock = Mock(url: URL(string: APIEndpoint.logout.urlString!)!, dataType: .json, statusCode: 200, data: [.post: mocked])
//        mock.register()
//
//        Current.rootStateMachine.handleLogout()
//
//        _ = XCTWaiter.wait(for: [self.expectation(description: "Wait for network call closure to complete")], timeout: 3.0)
//
//        XCTAssertNotNil(Current.apiClient.testResponseData)
//    }
    
    func test_netWorkLogout() throws {
        Current.apiClient.testResponseData = nil
        let mocked = try! JSONEncoder().encode(Self.logoutResponse)
        let mock = Mock(url: URL(string: APIEndpoint.logout.urlString!)!, dataType: .json, statusCode: 200, data: [.post: mocked])
        mock.register()

        Current.rootStateMachine.handleLogout()

        _ = XCTWaiter.wait(for: [self.expectation(description: "Wait for network call closure to complete")], timeout: 3.0)

        XCTAssertNotNil(Current.apiClient.testResponseData)
    }
    
    func test_network_requestMagicLink() throws {
        Current.apiClient.testResponseData = nil
        let mock = Mock(url: URL(string: APIEndpoint.magicLinks.urlString!)!, dataType: .json, statusCode: 200, data: [.post: Data()])
        mock.register()

        Current.rootStateMachine.requestMagicLink(email: "butters.is.grounded@gmail.com"){s,a in}

        _ = XCTWaiter.wait(for: [self.expectation(description: "Wait for network call closure to complete")], timeout: 3.0)

        XCTAssertNil(Current.apiClient.testResponseData)
    }
    
    func test_network_requestForgotPassword() throws {
        Current.apiClient.testResponseData = nil
        let mock = Mock(url: URL(string: APIEndpoint.forgotPassword.urlString!)!, dataType: .json, statusCode: 200, data: [.post: Data()])
        mock.register()

        Current.rootStateMachine.submitForgotPasswordRequest(forEmailAddress: "something@mail.com"){s,a in}

        _ = XCTWaiter.wait(for: [self.expectation(description: "Wait for network call closure to complete")], timeout: 3.0)

        XCTAssertNil(Current.apiClient.testResponseData)
    }


}
