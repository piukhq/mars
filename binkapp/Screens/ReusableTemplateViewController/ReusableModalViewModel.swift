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
    var primaryButtonAction: BinkButtonAction?
    var secondaryButtonTitle: String?
    var secondaryButtonAction: BinkButtonAction?
    
    init(title: String = "", text: NSMutableAttributedString, primaryButtonTitle: String? = nil, primaryButtonAction: BinkButtonAction? = nil, secondaryButtonTitle: String? = nil, secondaryButtonAction: BinkButtonAction? = nil) {
        self.title = title
        self.text = text
        self.primaryButtonTitle = primaryButtonTitle
        self.primaryButtonAction = primaryButtonAction
        self.secondaryButtonTitle = secondaryButtonTitle
        self.secondaryButtonAction = secondaryButtonAction
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
    
    var primaryButtonAction: BinkButtonAction? {
        return configurationModel.primaryButtonAction
    }
    
    var secondaryButtonTitle: String? {
        return configurationModel.secondaryButtonTitle
    }
    
    var secondaryButtonAction: BinkButtonAction? {
        return configurationModel.secondaryButtonAction
    }
    
    var shouldHideButtonsView: Bool {
        return primaryButtonTitle == nil && secondaryButtonTitle == nil
    }
    
    init(configurationModel: ReusableModalConfiguration) {
        self.configurationModel = configurationModel
    }
    
    func mainButtonWasTapped(completion: (BinkButtonAction)? = nil) {
        primaryButtonAction?()
    }
    
    func secondaryButtonWasTapped() {
        secondaryButtonAction?()
    }
}
