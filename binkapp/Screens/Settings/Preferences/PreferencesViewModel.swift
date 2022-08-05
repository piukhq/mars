//
//  PreferencesViewModel.swift
//  binkapp
//
//  Created by Paul Tiriteu on 20/11/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import UIKit

protocol PreferencesDelegate: AnyObject {
    func didReceivePreferences()
}

class PreferencesViewModel {
    private let repository = PreferencesRepository()
    
    weak var delegate: PreferencesDelegate?
    
    var preferences: [PreferencesModel] = [] {
        didSet {
            delegate?.didReceivePreferences()
        }
    }
    
    var descriptionText: AttributedString {
        var attributedString = AttributedString(L10n.preferencesScreenDescription)
        attributedString.font = .bodyTextLarge
        if let rewardsRange = attributedString.range(of: L10n.preferencesPromptHighlightRewards) {
            attributedString[rewardsRange].font = .subtitle
        }
        
        addFontAttributeToRange(attributedString: &attributedString, in: L10n.preferencesPromptHighlightRewards)
        addFontAttributeToRange(attributedString: &attributedString, in: L10n.preferencesPromptHighlightOffers)
        addFontAttributeToRange(attributedString: &attributedString, in: L10n.preferencesPromptHighlightUpdates)

        return attributedString
    }
    
    private func addFontAttributeToRange(attributedString: inout AttributedString, in range: String) {
        if let range = attributedString.range(of: range) {
            attributedString[range].font = .subtitle
        }
    }

    func getPreferences(onSuccess: @escaping ([PreferencesModel]) -> Void, onError: @escaping () -> Void) {
        guard repository.networkIsReachable else {
            presentNoConnectivityPopup()
            return
        }
        repository.getPreferences(onSuccess: { (preferences) in
            self.preferences = preferences
            onSuccess(preferences)
        }) { _ in
            onError()
        }
    }
    
    func putPreferences(preferences: [String: String], onSuccess: @escaping () -> Void, onError: @escaping (BinkError) -> Void) {
        repository.putPreferences(preferences: preferences, onSuccess: {
            onSuccess()
        }) { error in
            BinkLogger.error(UserLoggerError.updatePreferences, value: error.localizedDescription)
            onError(error)
        }
    }
    
    func presentNoConnectivityPopup() {
        let alert = ViewControllerFactory.makeNoConnectivityAlertController()
        let navigationRequest = AlertNavigationRequest(alertController: alert)
        Current.navigate.to(navigationRequest)
    }
}
