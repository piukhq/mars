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
    
    func getPreferences() {
        apiManager.doRequest(url: <#T##RequestURL#>, httpMethod: <#T##RequestHTTPMethod#>, parameters: <#T##[String : Any]?#>, onSuccess: <#T##(Decodable & Encodable) -> ()#>, onError: <#T##(Error) -> ()#>)
    }
}
