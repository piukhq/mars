//
//  LoyaltyWalletRouter.swift
//  binkapp
//
//  Copyright (c) 2019 Bink. All rights reserved.
//

import UIKit

@objc protocol LoyaltyWalletRoutingLogic
{
    
}

protocol LoyaltyWalletDataPassing
{
  var dataStore: LoyaltyWalletDataStore? { get }
}

class LoyaltyWalletRouter: NSObject, LoyaltyWalletRoutingLogic, LoyaltyWalletDataPassing
{
  weak var viewController: LoyaltyWalletViewController?
  var dataStore: LoyaltyWalletDataStore?
}
