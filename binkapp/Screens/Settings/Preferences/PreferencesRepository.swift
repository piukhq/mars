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

    func getPreferences(onSuccess: @escaping ([PreferencesModel]) -> Void, onError: @escaping (BinkError?) -> Void) {
        apiClient.performRequest(onEndpoint: .preferences, using: .get, expecting: [PreferencesModel].self, isUserDriven: false) { result in
            switch result {
            case .success(let preferences):
                onSuccess(preferences)
            case .failure(let error):
                onError(error)
            }
        }
    }
    
    func putPreferences(preferences: [String: String], onSuccess: @escaping () -> Void, onError: @escaping (BinkError) -> Void) {
        apiClient.performRequestWithNoResponse(onEndpoint: .preferences, using: .put, parameters: preferences, isUserDriven: true) { (success, error) in
            if let error = error {
                onError(error)
                return
            }
            onSuccess()
        }
    }
}
