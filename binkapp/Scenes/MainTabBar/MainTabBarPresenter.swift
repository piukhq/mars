//
//  MainTabBarPresenter.swift
//  binkapp
//
//  Copyright (c) 2019 Bink. All rights reserved.
//

import UIKit

protocol MainTabBarPresentationLogic
{
  func presentTabBar()
}

class MainTabBarPresenter: MainTabBarPresentationLogic
{
  weak var viewController: MainTabBarDisplayLogic?
  
  func presentTabBar()
  {
    let viewModel = MainTabBar.TabBarModels.ViewModel()
    viewController?.populateTabBar(viewModel: viewModel)
  }
}
