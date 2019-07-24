//
//  PaymentWalletRouter.swift
//  binkapp
//
//  Copyright (c) 2019 Bink. All rights reserved.
//

import UIKit

@objc protocol PaymentWalletRoutingLogic
{
    
}

protocol PaymentWalletDataPassing
{
  var dataStore: PaymentWalletDataStore? { get }
}

class PaymentWalletRouter: NSObject, PaymentWalletRoutingLogic, PaymentWalletDataPassing
{
  weak var viewController: PaymentWalletViewController?
  var dataStore: PaymentWalletDataStore?
}
