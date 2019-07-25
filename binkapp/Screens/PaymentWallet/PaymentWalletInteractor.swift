//
//  PaymentWalletInteractor.swift
//  binkapp
//
//  Copyright (c) 2019 Bink. All rights reserved.
//

import UIKit

protocol PaymentWalletBusinessLogic
{
  func doSomething(request: PaymentWallet.Something.Request)
}

protocol PaymentWalletDataStore
{
    
}

class PaymentWalletInteractor: PaymentWalletBusinessLogic, PaymentWalletDataStore
{
  var presenter: PaymentWalletPresentationLogic?
  var worker: PaymentWalletWorker?
  
  func doSomething(request: PaymentWallet.Something.Request)
  {
    worker = PaymentWalletWorker()
    worker?.doSomeWork()
    
    let response = PaymentWallet.Something.Response()
    presenter?.presentSomething(response: response)
  }
}
