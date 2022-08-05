//
//  PreferencesViewModel.swift
//  binkapp
//
//  Created by Paul Tiriteu on 20/11/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import UIKit

//protocol PreferencesDelegate: AnyObject {
//    func didReceivePreferences()
//}

class PreferencesViewModel: ObservableObject {
    @Published var showErrorText = false
    @Published var preferences: [PreferencesModel] = []
    
    private let repository = PreferencesRepository()
    
//    weak var delegate: PreferencesDelegate?
    
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

    func getPreferences() {
        guard repository.networkIsReachable else {
            presentNoConnectivityPopup()
            return
        }
        repository.getPreferences(onSuccess: { (preferences) in
            self.preferences = preferences
        }) { _ in
            self.showErrorText = true
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
    
    func clearStoredCredentials() {
        var alert: BinkAlertController
        do {
            try AutofillUtil.clearKeychain()
            alert = ViewControllerFactory.makeOkAlertViewController(title: L10n.preferencesClearCredentialsSuccessTitle, message: L10n.preferencesClearCredentialsSuccessBody)
        } catch {
            alert = ViewControllerFactory.makeOkAlertViewController(title: L10n.errorTitle, message: L10n.preferencesClearCredentialsError)
        }
        
        let navigationRequest = AlertNavigationRequest(alertController: alert)
        Current.navigate.to(navigationRequest)
    }
}
