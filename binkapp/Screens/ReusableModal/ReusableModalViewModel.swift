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
    var tabBarBackButton: UIBarButtonItem?
    let showCloseButton: Bool
    
    init(title: String = "", text: NSMutableAttributedString, primaryButtonTitle: String? = nil, mainButtonCompletion: @escaping (() -> Void) = { }, secondaryButtonTitle: String? = nil, secondaryButtonCompletion: @escaping (() -> Void) = { }, tabBarBackButton: UIBarButtonItem? = nil, showCloseButton: Bool = false) {
        self.title = title
        self.text = text
        self.primaryButtonTitle = primaryButtonTitle
        self.mainButtonCompletion = mainButtonCompletion
        self.secondaryButtonTitle = secondaryButtonTitle
        self.secondaryButtonCompletion = secondaryButtonCompletion
        self.tabBarBackButton = tabBarBackButton
        self.showCloseButton = showCloseButton
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
    
    var shouldHideButtonsView: Bool {
        return primaryButtonTitle == nil && secondaryButtonTitle == nil
    }
    
    var tabBarBackButton: UIBarButtonItem? {
        return configurationModel.tabBarBackButton
    }
    
    var showCloseButton: Bool {
        return configurationModel.showCloseButton
    }
    
    init(configurationModel: ReusableModalConfiguration, router: MainScreenRouter) {
        self.configurationModel = configurationModel
        self.router = router
    }
    
    func mainButtonWasTapped(completion: (() -> Void)? = nil) {
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
