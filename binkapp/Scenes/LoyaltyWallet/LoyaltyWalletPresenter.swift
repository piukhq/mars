//
//  LoyaltyWalletPresenter.swift
//  binkapp
//
//  Copyright (c) 2019 Bink. All rights reserved.
//

import UIKit

protocol LoyaltyWalletPresentationLogic
{
  func presentSomething(response: LoyaltyWallet.Something.Response)
}

class LoyaltyWalletPresenter: LoyaltyWalletPresentationLogic
{
  weak var viewController: LoyaltyWalletDisplayLogic?
  
  func presentSomething(response: LoyaltyWallet.Something.Response)
  {
    let viewModel = LoyaltyWallet.Something.ViewModel()
    viewController?.displaySomething(viewModel: viewModel)
  }
}
