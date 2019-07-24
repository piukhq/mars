//
//  LoyaltyWalletInteractor.swift
//  binkapp
//
//  Copyright (c) 2019 Bink. All rights reserved.
//

import UIKit

protocol LoyaltyWalletBusinessLogic
{
  func doSomething(request: LoyaltyWallet.Something.Request)
}

protocol LoyaltyWalletDataStore
{
    
}

class LoyaltyWalletInteractor: LoyaltyWalletBusinessLogic, LoyaltyWalletDataStore
{
  var presenter: LoyaltyWalletPresentationLogic?
  var worker: LoyaltyWalletWorker?
    
  func doSomething(request: LoyaltyWallet.Something.Request)
  {
    worker = LoyaltyWalletWorker()
    worker?.doSomeWork()
    
    let response = LoyaltyWallet.Something.Response()
    presenter?.presentSomething(response: response)
  }
}
