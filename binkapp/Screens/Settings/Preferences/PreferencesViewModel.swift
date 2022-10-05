//
//  PreferencesViewModel.swift
//  binkapp
//
//  Created by Paul Tiriteu on 20/11/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import UIKit

class PreferencesViewModel: NSObject, ObservableObject, UserServiceProtocol {
    @Published var errorText: String?
    @Published var preferences: [PreferencesModel] = []
    @Published var checkboxViewModels: [CheckboxViewModel] = []

    private let repository = PreferencesRepository()
    
    override init() {
        super.init()
        getPreferences()
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

    func getPreferences() {
        guard repository.networkIsReachable else {
            presentNoConnectivityPopup()
            return
        }
        repository.getPreferences(onSuccess: { preferences in
            preferences.forEach { preference in
                let checked: Bool = preference.value == "1"
                let attributedString = preference.slug == "marketing-bink" ? AttributedString(L10n.preferencesMarketingCheckbox) : AttributedString(preference.label ?? "")
                let viewModel = CheckboxViewModel(checkedState: checked, attributedText: attributedString, columnName: preference.slug, columnKind: .add)
                self.checkboxViewModels.append(viewModel)
                
                if preference.slug == AutofillUtil.slug {
                    Current.userDefaults.set(checked, forDefaultsKey: .rememberMyDetails)
                }
            }
        }) { _ in
            self.errorText = L10n.preferencesRetrieveFail
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
    
    func checkboxViewWasToggled(_ checkboxViewModel: CheckboxViewModel) {
        guard Current.apiClient.networkIsReachable else {
            presentNoConnectivityPopup()
            checkboxViewModel.reset()
            return
        }
        guard let columnName = checkboxViewModel.columnName else { return }

        let checkboxState = checkboxViewModel.checkedState ? "1" : "0"
        let dictionary = [columnName: checkboxState]

        if columnName == AutofillUtil.slug && checkboxViewModel.checkedState == false {
            let alert = ViewControllerFactory.makeOkCancelAlertViewController(title: L10n.preferencesClearCredentialsTitle, message: L10n.preferencesClearCredentialsBody, cancelButton: true) { [weak self] in
                self?.clearStoredCredentials()
            }
            let navigationRequest = AlertNavigationRequest(alertController: alert)
            Current.navigate.to(navigationRequest)
        }

        putPreferences(preferences: dictionary, onSuccess: { [weak self] in
            self?.errorText = nil
            if let _ = dictionary[AutofillUtil.slug] {
                Current.userDefaults.set(checkboxViewModel.checkedState, forDefaultsKey: .rememberMyDetails)
            }
        }) { [weak self] _ in
            checkboxViewModel.reset()
            self?.errorText = L10n.preferencesUpdateFail
        }
    }
    
    func configureUserPreferenceFromAPI() {
        getPreferences { result in
            switch result {
            case .success(let preferences):
                var value = preferences.first(where: { $0.slug == AutofillUtil.slug })?.value
                var checked: Bool = value == "1"
                Current.userDefaults.set(checked, forDefaultsKey: .rememberMyDetails)
                
                value = preferences.first(where: { $0.slug == BarcodeViewModel.alwaysShowBarcodePreferencesSlug })?.value
                checked = value == "1"
                Current.userDefaults.set(checked, forDefaultsKey: .showBarcodeAlways)
            case .failure:
                break
            }
        }
    }
}
