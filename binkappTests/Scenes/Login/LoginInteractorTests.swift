//
//  LoginInteractorTests.swift
//  binkapp
//
//  Copyright (c) 2019 Bink. All rights reserved.
//

@testable import binkapp
import XCTest

class LoginInteractorTests: XCTestCase {
  // MARK: Subject under test

  var sut: LoginInteractor!

  // MARK: Test lifecycle

  override func setUp() {
    super.setUp()
    setupLoginInteractor()
  }

  override func tearDown() {
    super.tearDown()
  }

  // MARK: Test setup

  func setupLoginInteractor() {
    sut = LoginInteractor()
  }

  // MARK: Test doubles

  class LoginPresentationLogicSpy: LoginPresentationLogic {
    var presentLoginCalled = false

    func presentLogin(response: Login.Something.Response) {
      presentLoginCalled = true
      presentLogin(response: response)
    }
  }

  // MARK: Dummy

  class LoginWorkerDummy: LoginWorker {
  //  override func login(email: String, completionHandler: @escaping <#type#>) {
//
//    }
  }

  // MARK: Tests

  func testDoSomething() {
    // Given
    let spy = LoginPresentationLogicSpy()
    sut.presenter = spy
    //let request = Login.Something.Request(email: <#String#>)

    // When
    sut.doSomething(request: request)

    // Then
    //XCTAssertTrue(spy.presentSomethingCalled, "doSomething(request:) should ask the presenter to format the result")
  }
}
