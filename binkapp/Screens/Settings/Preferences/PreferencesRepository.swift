//
//  PreferencesRepository.swift
//  binkapp
//
//  Created by Paul Tiriteu on 20/11/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

class PreferencesRepository {
    private let apiClient: APIClient
    
    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }
    
    var networkIsReachable: Bool {
        return apiClient.networkIsReachable
    }
    
    func getPreferences(onSuccess: @escaping ([PreferencesModel]) -> Void, onError: @escaping (Error?) -> Void) {
        apiClient.doRequest(url: .preferences, httpMethod: .get, isUserDriven: false, onSuccess: { (preferences: [PreferencesModel]) in
            onSuccess(preferences)
        }) { (error) in
            onError(error)
        }
    }
    
    func putPreferences(preferences: [String: String], onSuccess: @escaping () -> Void, onError: @escaping (Error) -> Void) {
        apiClient.doRequestWithNoResponse(url: .preferences, httpMethod: .put, parameters: preferences, isUserDriven: true) { (bool, error) in
            guard let safeError = error else {
                onSuccess()
                return
            }
            onError(safeError)
        }
    }
}
