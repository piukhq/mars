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

    // TODO: Fix completion handler
    func getPreferences(onSuccess: @escaping ([PreferencesModel]) -> Void, onError: @escaping (Error?) -> Void) {
        apiClient.performRequest(onEndpoint: .preferences, using: .get, expecting: [PreferencesModel].self, isUserDriven: false) { result in
            switch result {
            case .success(let preferences):
                onSuccess(preferences)
            case .failure(let error):
                onError(error)
            }
        }
    }
    
    func putPreferences(preferences: [String: String], onSuccess: @escaping () -> Void, onError: @escaping (Error) -> Void) {
        // TODO: Fix completion handler
        apiClient.performRequestWithParameters(onEndpoint: .preferences, using: .put, parameters: preferences, expecting: Nothing.self, isUserDriven: true) { result in
            switch result {
            case .success:
                onSuccess()
            case .failure(let error):
                onError(error)
            }
        }
    }
}
