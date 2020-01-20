//
//  PreferencesRepository.swift
//  binkapp
//
//  Created by Paul Tiriteu on 20/11/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

class PreferencesRepository {
    private let apiManager: ApiManager
    
    init(apiManager: ApiManager) {
        self.apiManager = apiManager
    }
    
    func getPreferences(onSuccess: @escaping ([PreferencesModel]) -> Void, onError: @escaping (Error?) -> Void) {
        // If offline, the red error text doesn't display
        apiManager.doRequest(url: .preferences, httpMethod: .get, isUserDriven: false, onSuccess: { (preferences: [PreferencesModel]) in
            onSuccess(preferences)
        }) { (error) in
            onError(error)
        }
    }
    
    func putPreferences(preferences: [String: String], onSuccess: @escaping () -> Void, onError: @escaping (Error) -> Void) {
        // Why doesn't alert view show on this call?
        apiManager.doRequestWithNoResponse(url: .preferences, httpMethod: .put, parameters: preferences, isUserDriven: true) { (bool, error) in
            guard let safeError = error else {
                onSuccess()
                return
            }
            onError(safeError)
        }
    }
}
