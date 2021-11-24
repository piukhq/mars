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
        case configFile
        
        var formattedKey: String {
            switch self {
            case .configFile:
                return "config_file"
            }
        }
    }
    
    private let remoteConfig = RemoteConfig.remoteConfig()
    private(set) var hasPerformedFetch = false
//    var recommendedVersionUtil = RecommendedVersionUtil()
    
    var configFile: RemoteConfigFile? {
        return objectForConfigKey(.configFile, forObjectType: RemoteConfigFile.self)
    }
    
    func configure() {
        setupRemoteConfig()
    }
    
    private func setupRemoteConfig() {
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        remoteConfig.configSettings = settings
    }
    
    func handleRemoteConfigFetch() {
        hasPerformedFetch = true
        Current.featureManager.getFeaturesFromRemoteConfig()
//        recommendedVersionUtil.promptRecommendedUpdateIfNecessary()
    }
    
    func fetch(completion: ((Bool) -> Void)? = nil) {
        remoteConfig.fetch { [weak self] (status, error) in
            guard let self = self else { return }
            if status == .success {
                self.remoteConfig.activate { (_, _) in
                    if #available(iOS 14.0, *) {
                        BinkLogger.info(event: AppLoggerEvent.fetchedRemoteConfig)
                    }
                    completion?(true)
                }
            } else {
                if #available(iOS 14.0, *) {
                    BinkLogger.error(AppLoggerError.remoteConfigFetchFailure, value: error?.localizedDescription)
                }
                completion?(false)
            }
        }
    }

    func objectForConfigKey<T: Codable>(_ configKey: RemoteConfigKey, forObjectType objectType: T.Type) -> T? {
        return remoteConfig.configValue(forKey: configKey.formattedKey).stringValue?.asDecodedObject(ofType: objectType)
    }
}
