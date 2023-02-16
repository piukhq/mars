//
//  LoginViewControllerTests.swift
//  binkappTests
//
//  Created by Ricardo Silva on 28/10/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import XCTest
import UIKit
import Mocker
@testable import binkapp

// swiftlint:disable all

final class LoginViewControllerTests: XCTestCase {

    static var sut = LoginViewController(formaDataSource: FormDataSource(accessForm: .magicLink, prefilledValues: [FormDataSource.PrefilledValue(commonName: .email, value: "email")]))
    func test_stackHasSubViews() throws {
        Self.sut.viewDidLoad()
        
        XCTAssertTrue(!Self.sut.stackScrollView.subviews.isEmpty)
    }
    
    func test_footerButtons_hasCorrectAmount() throws {
        Self.sut.viewDidLoad()
        
        XCTAssertTrue(Self.sut.footerButtons.count == 2)
    }
    
    func test_screenName_hasCorrectName() throws {
        Self.sut.viewDidLoad()
        Self.sut.viewDidAppear(false)
        
        XCTAssertTrue(Self.sut.screenName == "Login")
    }
    
    func test_loginTypeToggle() throws {
        Self.sut = LoginViewController(formaDataSource: FormDataSource(accessForm: .magicLink, prefilledValues: [FormDataSource.PrefilledValue(commonName: .email, value: "email")]))
        Self.sut.viewDidLoad()
        
        Self.sut.handleLoginTypeToggling()
        
        XCTAssertTrue(Self.sut.getLoginTypeButton().getTitle() == "Use magic link")
        XCTAssertTrue(Self.sut.titleLabel.text == "Log in")
        XCTAssertTrue(Self.sut.descriptionLabel.text == "Welcome back!")
        
        Self.sut.handleLoginTypeToggling()
        
        XCTAssertTrue(Self.sut.getLoginTypeButton().getTitle() == "Use a password")
        XCTAssertTrue(Self.sut.titleLabel.text == "Continue with email")
        
        let text = NSAttributedString(attributedString: Self.sut.textView.attributedText)
        
        let stringToCompare = "Get a link sent to your inbox so you can register or access your account instantly!\n\nNote: We will send you a Magic Link"
        XCTAssertTrue(text.string == stringToCompare)
    }
    
    func test_magicLinkTapped() throws {
        Self.sut.viewDidLoad()
        
        Self.sut.setLoginType(type: .magicLink)
        
        let mock = Mock(url: URL(string: APIEndpoint.magicLinks.urlString!)!, dataType: .json, statusCode: 200, data: [.post: Data()])
        mock.register()
        
        Self.sut.continueButtonTapped()
        
        _ = XCTWaiter.wait(for: [self.expectation(description: "Wait for network call closure to complete")], timeout: 5.0)
        
        XCTAssertTrue(Current.navigate.currentViewController!.isKind(of: CheckYourInboxViewController.self), "Current view controller is: \(String(describing: Current.navigate.currentViewController))")
    }
    
    func test_loginTapped() throws {
        Current.apiClient.testResponseData = nil
        
        Self.sut.viewDidLoad()
        
        Self.sut.setLoginType(type: .emailPassword)
        
        let loginResponse = LoginResponse(apiKey: "apiKey", userEmail: "ricksanchez@email.com", uid: "turkey-chicken-beef", accessToken: "accessToken")
        let mocked = try! JSONEncoder().encode(loginResponse)
        let mock = Mock(url: URL(string: APIEndpoint.login.urlString!)!, dataType: .json, statusCode: 200, data: [.post: mocked])
        mock.register()
        
        Self.sut.continueButtonTapped()
        
        _ = XCTWaiter.wait(for: [self.expectation(description: "Wait for network call closure to complete")], timeout: 5.0)
        
        XCTAssertNotNil(Current.apiClient.testResponseData)
    }
    
    func test_forgotPasswordWasTapped() throws {
        Self.sut.viewDidLoad()
        
        Self.sut.forgotPasswordTapped()
        
        XCTAssertTrue(Current.navigate.currentViewController!.isKind(of: ForgotPasswordViewController.self))
    }
    
    func test_presentLoginIssuesScreen() throws {
        Self.sut.viewDidLoad()
        
        Self.sut.presentLoginIssuesScreen()
        
        XCTAssertTrue(Current.navigate.currentViewController!.isKind(of: WebViewController.self))
    }
    
    func test_checkboxView() throws {
        Self.sut.viewDidLoad()
        
        Self.sut.checkboxView(didTapOn: URL(string: UIApplication.openSettingsURLString)!)
        
        XCTAssertTrue(Current.navigate.currentViewController!.isKind(of: WebViewController.self))
    }
}
