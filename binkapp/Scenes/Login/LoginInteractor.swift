//
//  LoginInteractor.swift
//  binkapp
//
//  Copyright (c) 2019 Bink. All rights reserved.
//

protocol LoginBusinessLogic {
  func login(request: Login.Request)
}

protocol LoginDataStore {
}

class LoginInteractor: LoginBusinessLogic, LoginDataStore {
  var presenter: LoginPresentationLogic?
  var worker: LoginWorker?

  func login(request: Login.Request) {
    worker = LoginWorker()
    worker?.login(email: "Bink20iteration1@testbink.com")

//    presenter?.presentSomething()
  }
}
