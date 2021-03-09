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
        case localPointsCollectionAuthFields(WebScrapable)
        case inAppReviewEnabled
        case dynamicActions
        case betaFeatures
        case betaUsers
        
        var formattedKey: String {
            let isDebug = !APIConstants.isProduction

            switch self {
            case .localPointsCollectionMasterEnabled:
                return "LPC_master_enabled\(isDebug ? "_debug" : "")"
            case .localPointsCollectionAgentEnabled(let agent):
                return "LPC_\(agent.merchant)_enabled\(isDebug ? "_debug" : "")"
            case .localPointsCollectionAuthFields(let agent):
                return "LPC_\(agent.merchant)_auth_fields\(isDebug ? "_debug" : "")"
            case .inAppReviewEnabled:
                return "in_app_review_enabled"
            case .dynamicActions:
                return "dynamic_actions"
            case .betaFeatures:
                return "beta_features"
            case .betaUsers:
                return "beta_users"
            }
        }
    }
    
    private let remoteConfig = RemoteConfig.remoteConfig()
    
    func configure() {
        setupRemoteConfig()
    }
    
    private func setupRemoteConfig() {
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        remoteConfig.configSettings = settings
        remoteConfig.setDefaults([RemoteConfigKey.localPointsCollectionMasterEnabled.formattedKey: NSNumber(value: false)])
        
        Current.pointsScrapingManager.agents.forEach {
            remoteConfig.setDefaults([RemoteConfigKey.localPointsCollectionAgentEnabled($0).formattedKey: NSNumber(value: false)])
        }
        
        fetch()
    }
    
    private func handleRemoteConfigFetch() {
        Current.featureManager.getFeaturesFromRemoteConfig()
    }
    
    func fetch(completion: (() -> Void)? = nil) {
        remoteConfig.fetch { [weak self] (status, error) in
            guard let self = self else { return }
            if status == .success {
                self.remoteConfig.activate { (_, _) in
                    DispatchQueue.main.async {
                        self.handleRemoteConfigFetch()
                    }
                    if #available(iOS 14.0, *) {
                        BinkLogger.info(.fetchedRemoteConfig, value: nil, category: .remoteConfigUtil)
                    }
                    completion?()
                }
            } else {
                if #available(iOS 14.0, *) {
                    BinkLogger.error(.remoteConfigFetchFailure, value: error?.localizedDescription, category: .remoteConfigUtil)
                }
                completion?()
            }
        }
    }
    
    func boolValueForConfigKey(_ configKey: RemoteConfigKey) -> Bool {
        return remoteConfig.configValue(forKey: configKey.formattedKey).boolValue
    }

    func objectForConfigKey<T: Codable>(_ configKey: RemoteConfigKey, forObjectType objectType: T.Type) -> T? {
        return remoteConfig.configValue(forKey: configKey.formattedKey).stringValue?.asDecodedObject(ofType: objectType)
    }
}
