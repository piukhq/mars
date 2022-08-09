//
//  PreferencesViewModel.swift
//  binkapp
//
//  Created by Paul Tiriteu on 20/11/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

protocol PreferencesDelegate: AnyObject {
    func didReceivePreferences()
}

class PreferencesViewModel: UserServiceProtocol {
    private let repository = PreferencesRepository()
    
    weak var delegate: PreferencesDelegate?
    
    var preferences: [PreferencesModel] = [] {
        didSet {
            delegate?.didReceivePreferences()
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
    
    func configureUserPreferenceFromAPI() {
        getPreferences { result in
            switch result {
            case .success(let preferences):
                var value = preferences.first(where: { $0.slug == AutofillUtil.slug })?.value
                var checked: Bool = value == "1"
                Current.userDefaults.set(checked, forDefaultsKey: .rememberMyDetails)
                
                value = preferences.first(where: { $0.slug == L10n.alwaysShowBarcodePreference })?.value
                checked = value == "1"
                Current.userDefaults.set(checked, forDefaultsKey: .showBarcodeAlways)
            case .failure:
                break
            }
        }
    }
}
