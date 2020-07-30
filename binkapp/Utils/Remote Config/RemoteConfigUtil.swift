//
//  RemoteConfigUtil.swift
//  binkapp
//
//  Created by Nick Farrant on 30/07/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import Foundation
import FirebaseRemoteConfig

class RemoteConfigUtil {
    enum RemoteConfigKey {
        case localPointsCollectionMasterEnabled
        case localPointsCollectionAgentEnabled(WebScrapable)
        
        var formattedKey: String {
            switch self {
            case .localPointsCollectionMasterEnabled:
                return "LPC_master_enabled"
            case .localPointsCollectionAgentEnabled(let agent):
                return "LPC_\(agent.merchant)_enabled"
            }
        }
    }
    
    private let remoteConfig = RemoteConfig.remoteConfig()
    
    init() {
        setupRemoteConfig()
    }
    
    private func setupRemoteConfig() {
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        remoteConfig.configSettings = settings
//        remoteConfig.setDefaults([RemoteConfigKey.localPointsCollectionMasterEnabled.formattedKey: NSNumber(value: true)])
        fetch()
    }
    
    func fetch(completion: (() -> Void)? = nil) {
        remoteConfig.fetch { [weak self] (status, _) in
            guard let self = self else { return }
            if status == .success {
                self.remoteConfig.activate(completionHandler: { _ in
                    completion?()
                })
            } else {
                completion?()
            }
        }
    }
    
    func boolValueForConfigKey(_ configKey: RemoteConfigKey) -> Bool {
        return remoteConfig.configValue(forKey: configKey.formattedKey).boolValue
    }
}
