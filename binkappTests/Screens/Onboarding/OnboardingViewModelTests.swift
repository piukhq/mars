//
//  OnboardingViewModelTests.swift
//  binkappTests
//
//  Created by Ricardo Silva on 21/08/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import XCTest
@testable import binkapp

// swiftlint:disable all

class OnboardingViewModelTests: XCTestCase {
    var currentViewController: UIViewController {
        return Current.navigate.currentViewController!
    }
    
    static var viewModel: OnboardingViewModel!
    
    override class func setUp() {
        viewModel = OnboardingViewModel()
    }
    
    func test_loginText() throws {
        XCTAssertEqual(Self.viewModel.loginWithEmailButtonText, L10n.loginWithEmailButton)
    }

    func test_pushToSocialTermsAndConditions_navigatesToCorrectViewController() {
        let loginRequest = SignInWithAppleRequest(authorizationCode: "")
        Self.viewModel.pushToSocialTermsAndConditions(requestType: .apple(loginRequest))
        XCTAssertTrue(currentViewController.isKind(of: TermsAndConditionsViewController.self))
    }
    
    func test_pushToToLogin_navigatesToCorrectViewController() {
        Self.viewModel.pushToLogin()
        XCTAssertTrue(currentViewController.isKind(of: LoginViewController.self))
    }
    
    func test_openDebugMenu_navigatesToCorrectViewController() {
        Self.viewModel.openDebugMenu()
        XCTAssertTrue(currentViewController.isKind(of: UIViewController.self))
    }

}
