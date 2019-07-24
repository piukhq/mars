//
//  MainTabBarInteractor.swift
//  binkapp
//
//  Copyright (c) 2019 Bink. All rights reserved.
//

import UIKit

protocol MainTabBarBusinessLogic
{
    func populateTabBar()
}

protocol MainTabBarDataStore
{
    
}

class MainTabBarInteractor: MainTabBarBusinessLogic, MainTabBarDataStore
{
    var presenter: MainTabBarPresentationLogic?
    var worker: MainTabBarWorker?
    
    func populateTabBar()
    {
        presenter?.presentTabBar()
    }
}

