//
//  RecommendedVersionUtil.swift
//  binkapp
//
//  Created by Nick Farrant on 10/05/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import UIKit

class RecommendedVersionUtil {
    private var canShowRecommendedUpdatePrompt = true
    
    func doesDeviceMeetRequirements() -> Bool {
        let components = UIDevice.current.modelName.components(separatedBy: ",")
        
        if let name = components.first {
            if let number = Int(name.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()) {
                // Is above Iphone6 or above iPod 6th Gen?
                let unsupportedVersionNumber = 7
                return number > unsupportedVersionNumber ? true : false
            }
        }
        
        return true
    }
    
    func promptRecommendedUpdateIfNecessary() {
        ///  Don't show if the device is not iOS15 compatible
        if !doesDeviceMeetRequirements() { return }
        
        /// Don't show prompt if running UI tests
        if UIApplication.isRunningUITests { return }
        
        /// We must have performed a remote config fetch, and we must have not have prompted already
        guard Current.remoteConfig.hasPerformedFetch else { return }
        guard canShowRecommendedUpdatePrompt else { return }
        
        /// By calling this here, if there is no update recommended at launch, but this changes on remote config before the app is relaunched,
        /// this stops a pull-to-refresh triggering the alert.
        canShowRecommendedUpdatePrompt = false
        guard updateIsRecommended else { return }
        if recommendedVersionWasSkipped { return }
        
        let alert = ViewControllerFactory.makeRecommendedAppUpdateAlertController { [weak self] in
            self?.skipVersion()
            BinkAnalytics.track(RecommendedAppUpdateAnalyticsEvent.skipThisVersion)
        }
        
        let request = AlertNavigationRequest(alertController: alert)
        Current.navigate.to(request)
    }
    
    private var recommendedLiveVersion: AppVersion? {
        let appConfig = Current.remoteConfig.configFile?.appConfig
        guard let versionString = appConfig?.recommendedLiveAppVersion?.ios else { return nil }
        return AppVersion(versionString: versionString)
    }
    
    private var updateIsRecommended: Bool {
        guard let currentVersion = Bundle.currentVersion else { return false }
        return recommendedLiveVersion?.isMoreRecentThanVersion(currentVersion) == true
    }
    
    private var recommendedVersionWasSkipped: Bool {
        guard let skippedVersions = Current.userDefaults.value(forDefaultsKey: .skippedRecommendedVersions) as? [String] else { return false }
        guard let versionString = recommendedLiveVersion?.versionString else { return false }
        return skippedVersions.contains(versionString)
    }
    
    private func skipVersion() {
        guard let versionString = recommendedLiveVersion?.versionString else { return }
        var skippedVersions = Current.userDefaults.value(forDefaultsKey: .skippedRecommendedVersions) as? [String]
        skippedVersions?.append(versionString)
        Current.userDefaults.set(skippedVersions ?? [versionString], forDefaultsKey: .skippedRecommendedVersions)
    }
}
