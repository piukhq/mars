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
    var mainButtonTitle: String?
    var mainButtonCompletion: () -> Void?
    var secondaryButtonTitle: String?
    var secondaryButtonCompletion: () -> Void?
    
    init(title: String = "", text: NSMutableAttributedString, mainButtonTitle: String? = nil, mainButtonCompletion: (() -> Void)? = nil, secondaryButtonTitle: String? = nil, secondaryButtonCompletion: (() -> Void)? = nil) {
        self.title = title
        self.text = text
        self.mainButtonTitle = mainButtonTitle
        self.mainButtonCompletion = mainButtonCompletion ?? {  }
        self.secondaryButtonTitle = secondaryButtonTitle
        self.secondaryButtonCompletion = secondaryButtonCompletion ?? {  }
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
    
    var mainButtonTitle: String? {
        return configurationModel.mainButtonTitle
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
