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
    
    func getPreferences(onSuccess: @escaping ([PreferencesModel]) -> Void, onError: @escaping (Error) -> Void) {
        apiManager.doRequest(url: .preferences, httpMethod: .get, onSuccess: { (preferences: [PreferencesModel]) in
            onSuccess(preferences)
        }) { (error) in
            onError(error)
        }
    }
    
    func putPreferences(preferences: [String: String], onSuccess: @escaping () -> Void, onError: @escaping (Error) -> Void) {

        apiManager.doRequestWithNoResponse(url: .preferences, httpMethod: .put, parameters: preferences) { (bool, error) in
            guard let safeError = error else {
                onSuccess()
                return
            }
            onError(safeError)
        }
    }
}
