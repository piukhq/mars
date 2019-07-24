//
//  AddCardInteractor.swift
//  binkapp
//
//  Copyright (c) 2019 Bink. All rights reserved.
//

import UIKit

protocol AddCardBusinessLogic
{
  func doSomething(request: AddCard.Something.Request)
}

protocol AddCardDataStore
{
    
}

class AddCardInteractor: AddCardBusinessLogic, AddCardDataStore
{
  var presenter: AddCardPresentationLogic?
  var worker: AddCardWorker?
    
  func doSomething(request: AddCard.Something.Request)
  {
    worker = AddCardWorker()
    worker?.doSomeWork()
    
    let response = AddCard.Something.Response()
    presenter?.presentSomething(response: response)
  }
}
