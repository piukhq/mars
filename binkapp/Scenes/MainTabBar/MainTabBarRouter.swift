//
//  MainTabBarRouter.swift
//  binkapp
//
//  Copyright (c) 2019 Bink. All rights reserved.
//

import UIKit

@objc protocol MainTabBarRoutingLogic
{
    
}

protocol MainTabBarDataPassing
{
  var dataStore: MainTabBarDataStore? { get }
}

class MainTabBarRouter: NSObject, MainTabBarRoutingLogic, MainTabBarDataPassing
{
  weak var viewController: MainTabBarViewController?
  var dataStore: MainTabBarDataStore?
}
