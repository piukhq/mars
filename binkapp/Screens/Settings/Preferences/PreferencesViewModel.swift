//
//  PreferencesViewModel.swift
//  binkapp
//
//  Created by Paul Tiriteu on 20/11/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

protocol PreferencesDelegate: class {
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
            if #available(iOS 14.0, *) {
                BinkLogger.error(.updatePreferences, value: error.localizedDescription, category: .preferencesViewModel)
            }
            onError(error)
        }
    }
    
    func presentNoConnectivityPopup() {
        let alert = ViewControllerFactory.makeNoConnectivityAlertController()
        let navigationRequest = AlertNavigationRequest(alertController: alert)
        Current.navigate.to(navigationRequest)
    }
}
