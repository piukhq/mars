//
//  LoginInteractor.swift
//  binkapp
//
//  Created by Karl Sigiscar on 04/07/2019.
//  Copyright (c) 2019 Bink. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

protocol LoginBusinessLogic
{
  func doSomething(request: Login.Something.Request)
}

protocol LoginDataStore
{
  //var name: String { get set }
}

class LoginInteractor: LoginBusinessLogic, LoginDataStore
{
  var presenter: LoginPresentationLogic?
  var worker: LoginWorker?
  //var name: String = ""
  
  // MARK: Do something
  
  func doSomething(request: Login.Something.Request)
  {
    worker = LoginWorker()
    worker?.doSomeWork()
    
    let response = Login.Something.Response()
    presenter?.presentSomething(response: response)
  }
}
