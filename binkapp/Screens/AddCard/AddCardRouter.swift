//
//  AddCardRouter.swift
//  binkapp
//
//  Copyright (c) 2019 Bink. All rights reserved.
//

import UIKit

@objc protocol AddCardRoutingLogic
{
    
}

protocol AddCardDataPassing
{
  var dataStore: AddCardDataStore? { get }
}

class AddCardRouter: NSObject, AddCardRoutingLogic, AddCardDataPassing
{
  weak var viewController: AddCardViewController?
  var dataStore: AddCardDataStore?
}
