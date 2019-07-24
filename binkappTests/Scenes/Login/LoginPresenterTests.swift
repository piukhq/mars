//
//  LoginPresenterTests.swift
//  binkapp
//
//  Copyright (c) 2019 Bink. All rights reserved.
//

@testable import binkapp
import XCTest

class LoginPresenterTests: XCTestCase {
  // MARK: Subject under test

  var sut: LoginPresenter!

  // MARK: Test lifecycle

  override func setUp() {
    super.setUp()
    setupLoginPresenter()
  }

  override func tearDown() {
    super.tearDown()
  }

  // MARK: Test setup

  func setupLoginPresenter() {
    sut = LoginPresenter()
  }

  // MARK: Test doubles

  class LoginDisplayLogicSpy: LoginDisplayLogic {
    var displaySomethingCalled = false

    func displaySomething(viewModel: Login.Something.ViewModel) {
      displaySomethingCalled = true
    }
  }

  // MARK: Tests

  func testPresentSomething() {
    // Given
    let spy = LoginDisplayLogicSpy()
    sut.viewController = spy
    let response = Login.Something.Response()

    // When
    sut.presentLogin(response: response)

    // Then
    XCTAssertTrue(spy.displaySomethingCalled, "presentSomething(response:) should ask the view controller to display the result")
  }
}
