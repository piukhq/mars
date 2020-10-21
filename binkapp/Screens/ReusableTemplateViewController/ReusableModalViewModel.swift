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
    
    init(title: String = "", text: NSMutableAttributedString, primaryButtonTitle: String? = nil, mainButtonCompletion: @escaping (() -> Void) = { }, secondaryButtonTitle: String? = nil, secondaryButtonCompletion: @escaping (() -> Void) = { }) {
        self.title = title
        self.text = text
        self.primaryButtonTitle = primaryButtonTitle
        self.mainButtonCompletion = mainButtonCompletion
        self.secondaryButtonTitle = secondaryButtonTitle
        self.secondaryButtonCompletion = secondaryButtonCompletion
    }

    static func makeAttributedString(title: String, description: String) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString()
        let attributedTitle = NSAttributedString(string: title + "\n", attributes: [NSAttributedString.Key.font: UIFont.headline])
        let attributedBody = NSAttributedString(string: description, attributes: [NSAttributedString.Key.font: UIFont.bodyTextLarge])
        attributedString.append(attributedTitle)
        attributedString.append(attributedBody)

        return attributedString
    }
}

open class ReusableModalViewModel {
    private let configurationModel: ReusableModalConfiguration
    
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
    
    init(configurationModel: ReusableModalConfiguration) {
        self.configurationModel = configurationModel
    }
    
    func mainButtonWasTapped(completion: (() -> Void)? = nil) {
        mainButtonCompletion()
    }
    
    func secondaryButtonWasTapped() {
        secondaryButtonCompletion()
    }
}
