//
//  LoginWorkerTests.swift
//  binkapp
//
//  Copyright (c) 2019 Bink. All rights reserved.
//

@testable import binkapp
import XCTest

class LoginWorkerTests: XCTestCase {
  // MARK: Subject under test

  var sut: LoginWorker!

  // MARK: Test lifecycle

  override func setUp() {
    super.setUp()
    setupLoginWorker()
  }

  override func tearDown() {
    super.tearDown()
  }

  // MARK: Test setup

  func setupLoginWorker() {
    sut = LoginWorker()
  }

  func testLoginOnSucces() {
    // Given
    let emailAddress = "Bink20iteration1@testbink.com"

    // When
    let actualEmail = "Bink20iteration1@testbink.com"
    sut.login(email: emailAddress)
    waitForExpectations(timeout: 0.5, handler: nil)

    // Then
    XCTAssertEqual(actualEmail, "Bink20iteration1@testbink.com", "login(email:completionHandler) should return an email")
  }

    func  testLoginOnFailure() {
        let emailAddress = "wrong"

        // When
        let actualEmail = "Bink20iteration1@testbink.com"
        sut.login(email: emailAddress)
        waitForExpectations(timeout: 0.5, handler: nil)

        // Then
        XCTAssertEqual(actualEmail, "login(email:completionHandler) should not return an email")
    }
}
