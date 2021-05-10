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
        case appConfiguration
        
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
            case .appConfiguration:
                return "app_configuration"
            }
        }
    }
    
    private let remoteConfig = RemoteConfig.remoteConfig()
    
    private(set) var hasPerformedFetch = false
    
    /// A tool based on the app_configuration object in remote config
    var appConfiguration = RemoteAppConfigurationUtil()
    
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
        hasPerformedFetch = true
        Current.featureManager.getFeaturesFromRemoteConfig()
        appConfiguration.promptRecommendedUpdateIfNecessary()
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
                        BinkLogger.info(event: AppLoggerEvent.fetchedRemoteConfig)
                    }
                    completion?()
                }
            } else {
                if #available(iOS 14.0, *) {
                    BinkLogger.error(AppLoggerError.remoteConfigFetchFailure, value: error?.localizedDescription)
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

struct RemoteAppConfigurationUtil {
    private var canShowPrompt = true
    
    mutating func promptRecommendedUpdateIfNecessary() {
        // We must have performed a remote config fetch, and we must have not have prompted already
        
        guard Current.remoteConfig.hasPerformedFetch else { return }
        guard canShowPrompt else { return }
        guard updateIsRecommended else { return }
        
        canShowPrompt = false
        
        let alert = BinkAlertController(title: "App Update Available", message: "Get the latest version of the Bink app (\(recommendedLiveVersion ?? "")).", preferredStyle: .alert)
        let openAppStoreAction = UIAlertAction(title: "Open App Store", style: .default) { _ in
            guard let url = URL(string: "https://apps.apple.com/gb/app/bink-loyalty-rewards-wallet/id1142153931"), UIApplication.shared.canOpenURL(url) else { return }
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        let maybeLaterAction = UIAlertAction(title: "Maybe later", style: .default, handler: nil)
        let skipVersionAction = UIAlertAction(title: "Skip this version", style: .default, handler: nil)
        alert.addAction(openAppStoreAction)
        alert.addAction(maybeLaterAction)
        alert.addAction(skipVersionAction)
        let request = AlertNavigationRequest(alertController: alert)
        Current.navigate.to(request)
    }
    
    private var recommendedLiveVersion: String? {
        let appConfiguration = Current.remoteConfig.objectForConfigKey(.appConfiguration, forObjectType: AppConfiguration.self)
        return appConfiguration?.recommendedLiveAppVersion?.iOS
    }
    
    private var updateIsRecommended: Bool {
        // Break recommended version into components
        guard let recommendedLiveVersion = recommendedLiveVersion else { return false }
        guard let components = VersionComponent.components(from: recommendedLiveVersion, expecting: [.major, .minor, .patch]) else { return false }
        
        // If recommended major is higher than local, return true
        // If recommended major is lower than local, return false
        guard let recommendedMajor = VersionComponent.value(component: .major, from: components), let currentMajor = Bundle.majorVersion else { return false }
        if recommendedMajor > currentMajor { return true }
        if currentMajor > recommendedMajor { return false }
        // If recommended major is the same as local, move to minor
        
        // If recommended minor is higher than local, return true
        // If recommended minor is lower than local, return false
        guard let recommendedMinor = VersionComponent.value(component: .minor, from: components), let currentMinor = Bundle.minorVersion else { return false }
        if recommendedMinor > currentMinor { return true }
        if currentMinor > recommendedMinor { return false }
        // If recommended minor is the same as local, move to patch
        
        // If recommended patch is higher than local, return true
        // If recommended patch is lower than local, return false
        guard let recommendedPatch = VersionComponent.value(component: .patch, from: components), let currentPatch = Bundle.patchVersion else { return false }
        if recommendedPatch > currentPatch { return true }
        if currentPatch > recommendedPatch { return false }
        
        // If recommended patch is the same as local, return false
        return false
    }
}
