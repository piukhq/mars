//
//  LoginPresenter.swift
//  binkapp
//
//  Copyright (c) 2019 Bink. All rights reserved.
//

import UIKit

protocol LoginPresentationLogic {
  func presentLogin(response: Login.Response)
}

class LoginPresenter: LoginPresentationLogic {
  weak var viewController: LoginDisplayLogic?

    func presentLogin(response: Login.Response) {
        //TODO: Implement this method
  }
}
