//
//  AppConfiguration.swift
//  binkapp
//
//  Created by Nick Farrant on 10/05/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import UIKit

struct AppConfiguration: Codable {
    let recommendedLiveAppVersion: RecommendedLiveAppVersion?
    
    enum CodingKeys: String, CodingKey {
        case recommendedLiveAppVersion = "recommended_live_app_version"
    }
    
    struct RecommendedLiveAppVersion: Codable {
        let iOS: String?
        let android: String?
        
        enum CodingKeys: String, CodingKey {
            case iOS = "ios_version"
            case android = "android_version"
        }
    }
}

class RemoteAppConfigurationUtil {
    private var canShowPrompt = true
    
    func promptRecommendedUpdateIfNecessary() {
        /// We must have performed a remote config fetch, and we must have not have prompted already
        guard Current.remoteConfig.hasPerformedFetch else { return }
        guard canShowPrompt else { return }
        
        /// By calling this here, if there is no update recommended at launch, but this changes on remote config before the app is relaunched,
        /// this stops a pull-to-refresh triggering the alert.
        canShowPrompt = false
        guard updateIsRecommended else { return }
        guard !recommendedVersionWasSkipped else { return }
        
        let alert = BinkAlertController(title: "App Update Available", message: "Get the latest version of the Bink app (\(recommendedLiveVersion ?? "")).", preferredStyle: .alert)
        let openAppStoreAction = UIAlertAction(title: "Open App Store", style: .default) { _ in
            guard let url = URL(string: "https://apps.apple.com/gb/app/bink-loyalty-rewards-wallet/id1142153931"), UIApplication.shared.canOpenURL(url) else { return }
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        let maybeLaterAction = UIAlertAction(title: "Maybe later", style: .default, handler: nil)
        let skipVersionAction = UIAlertAction(title: "Skip this version", style: .default) { [weak self] _ in
            guard let self = self else { return }
            guard let version = AppVersion(versionString: self.recommendedLiveVersion) else { return }
            self.skipVersion(version)
        }
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
        guard let recommendedLiveVersion = AppVersion(versionString: recommendedLiveVersion) else { return false }
        return recommendedLiveVersion.isMoreRecentThanCurrentVersion
    }
    
    private var recommendedVersionWasSkipped: Bool {
        guard let skippedVersions = Current.userDefaults.value(forDefaultsKey: .skippedRecommendedVersions) as? [String] else { return false }
        guard let versionString = recommendedLiveVersion else { return false }
        return skippedVersions.contains(versionString)
    }
    
    private func skipVersion(_ version: AppVersion) {
        let versionString = version.versionString
        var skippedVersions = Current.userDefaults.value(forDefaultsKey: .skippedRecommendedVersions) as? [String]
        skippedVersions?.append(versionString)
        Current.userDefaults.set(skippedVersions ?? [versionString], forDefaultsKey: .skippedRecommendedVersions)
    }
}
