//
//  ReusableModalViewModel.swift
//  binkapp
//
//  Created by Paul Tiriteu on 25/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

public struct ReusableModalConfiguration {
    var title: String
    var text: NSMutableAttributedString
    var primaryButtonTitle: String?
    var mainButtonCompletion: () -> Void?
    var secondaryButtonTitle: String?
    var secondaryButtonCompletion: () -> Void?
    var tabBarBackButton: UIBarButtonItem
    
    init(title: String = "", text: NSMutableAttributedString, primaryButtonTitle: String? = nil, mainButtonCompletion: @escaping (() -> Void) = { }, secondaryButtonTitle: String? = nil, secondaryButtonCompletion: @escaping (() -> Void) = { }, tabBarBackButton: UIBarButtonItem) {
        self.title = title
        self.text = text
        self.primaryButtonTitle = primaryButtonTitle
        self.mainButtonCompletion = mainButtonCompletion
        self.secondaryButtonTitle = secondaryButtonTitle
        self.secondaryButtonCompletion = secondaryButtonCompletion
        self.tabBarBackButton = tabBarBackButton
    }
}

open class ReusableModalViewModel {
    private let configurationModel: ReusableModalConfiguration
    let router: MainScreenRouter
    
    var title: String {
        return configurationModel.title
    }
    
    var text: NSMutableAttributedString {
        return configurationModel.text
    }
    
    var primaryButtonTitle: String? {
        return configurationModel.primaryButtonTitle
    }
    
    var mainButtonCompletion: () -> Void? {
        return configurationModel.mainButtonCompletion
    }
    
    var secondaryButtonTitle: String? {
        return configurationModel.secondaryButtonTitle
    }
    
    var secondaryButtonCompletion: () -> Void? {
        return configurationModel.secondaryButtonCompletion
    }
    
    var tabBarBackButton: UIBarButtonItem {
        return configurationModel.tabBarBackButton
    }
    
    init(configurationModel: ReusableModalConfiguration, router: MainScreenRouter) {
        self.configurationModel = configurationModel
        self.router = router
    }
    
    func mainButtonWasTapped() {
        mainButtonCompletion()
    }
    
    func secondaryButtonWasTapped() {
        secondaryButtonCompletion()
    }
    
    func popViewController() {
        router.popViewController()
    }
    
    func toRootViewController()  {
        router.popToRootViewController()
    }
}
