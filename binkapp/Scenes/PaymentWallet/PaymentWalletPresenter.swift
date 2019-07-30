//
//  PaymentWalletPresenter.swift
//  binkapp
//
//  Copyright (c) 2019 Bink. All rights reserved.
//

import UIKit

protocol PaymentWalletPresentationLogic
{
  func presentSomething(response: PaymentWallet.Something.Response)
}

class PaymentWalletPresenter: PaymentWalletPresentationLogic
{
  weak var viewController: PaymentWalletDisplayLogic?
  
  func presentSomething(response: PaymentWallet.Something.Response)
  {
    let viewModel = PaymentWallet.Something.ViewModel()
    viewController?.displaySomething(viewModel: viewModel)
  }
}
