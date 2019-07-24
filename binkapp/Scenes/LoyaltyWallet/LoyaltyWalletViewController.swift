//
//  LoyaltyWalletViewController.swift
//  binkapp
//
//  Copyright (c) 2019 Bink. All rights reserved.
//

import UIKit

protocol LoyaltyWalletDisplayLogic: class
{
  func displaySomething(viewModel: LoyaltyWallet.Something.ViewModel)
}

class LoyaltyWalletViewController: UIViewController, LoyaltyWalletDisplayLogic
{
  var interactor: LoyaltyWalletBusinessLogic?
  var router: (NSObjectProtocol & LoyaltyWalletRoutingLogic & LoyaltyWalletDataPassing)?

  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)
  {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    setup()
  }
  
  required init?(coder aDecoder: NSCoder)
  {
    super.init(coder: aDecoder)
    setup()
  }
  
  private func setup()
  {
    let viewController = self
    let interactor = LoyaltyWalletInteractor()
    let presenter = LoyaltyWalletPresenter()
    let router = LoyaltyWalletRouter()
    viewController.interactor = interactor
    viewController.router = router
    interactor.presenter = presenter
    presenter.viewController = viewController
    router.viewController = viewController
    router.dataStore = interactor
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?)
  {
    if let scene = segue.identifier {
      let selector = NSSelectorFromString("routeTo\(scene)WithSegue:")
      if let router = router, router.responds(to: selector) {
        router.perform(selector, with: segue)
      }
    }
  }
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    doSomething()
  }
  
  func doSomething()
  {
    let request = LoyaltyWallet.Something.Request()
    interactor?.doSomething(request: request)
  }
  
  func displaySomething(viewModel: LoyaltyWallet.Something.ViewModel)
  {
    
  }
}
