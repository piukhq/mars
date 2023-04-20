//
//  World.swift
//  binkapp
//
//  Created by Nick Farrant on 19/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

let Current = World()

class World {
    lazy var database = Database(named: "binkapp")
    lazy var wallet = Wallet()
    lazy var userDefaults: BinkUserDefaults = UserDefaults.standard
    lazy var userManager = UserManager()
    lazy var loginController = LoginController()
    lazy var apiClient = APIClient()
    lazy var navigate = Navigate()
    lazy var rootStateMachine = RootStateMachine()
    lazy var pointsScrapingManager = PointsScrapingManager()
    lazy var remoteConfig = RemoteConfigUtil()
    lazy var featureManager = FeatureTogglingManager()
    lazy var themeManager = ThemeManager()
    lazy var watchController = WatchController()
    lazy var dateManager = DateManager()
    lazy var firestoreManager = FirestoreManager()

    var onboardingTrackingId: String? // Stored to provide a consistent id from start to finish of onboarding, reset upon a new journey
    var inAppReviewableJourney: Any? // We cast this to the correct type using generics when we need to
    
    private let prodBundleIdentifier = "com.bink.wallet"

    var isReleaseTypeBuild: Bool {
        guard let bundleIdentifier = Bundle.main.bundleIdentifier else {
            // I can't imagine a scenario where this would be not set?
            return false
        }
        
        return bundleIdentifier == prodBundleIdentifier
    }
}

protocol BinkUserDefaults {
    // BinkUserDefaults specific methods supporting Keys
    func set(_ value: Any?, forDefaultsKey defaultName: UserDefaults.Keys)
    func string(forDefaultsKey defaultName: UserDefaults.Keys) -> String?
    func bool(forDefaultsKey defaultName: UserDefaults.Keys) -> Bool
    func value(forDefaultsKey defaultName: UserDefaults.Keys) -> Any?

    // UserDefault methods where we cannot support Keys
    func set(_ value: Any?, forKey defaultName: String)
    func string(forKey defaultName: String) -> String?
    func bool(forKey defaultName: String) -> Bool
    func value(forKey defaultName: String) -> Any?
}

extension UserDefaults: BinkUserDefaults {
    enum Keys {
        case hasLaunchedWallet
        case debugBaseURL
        case webScrapingCookies(membershipCardId: String)
        case responseCodeVisualiser
        case inAppReviewLastRequestedDate
        case inAppReviewRequestedMinorVersions
        case applyInAppReviewRules
        case allowCustomBundleClientOnLogin
        case membershipCardMostRecentTransaction(membershipCardId: String)
        case appLaunches
        case hasPreviouslyLaunchedApp
        case localWalletOrder(userId: String, walletType: Wallet.WalletType)
        case theme
        case featureFlags
        case skippedRecommendedVersions
        case lpcDebugMode
        case hasCurrentUser
        case installedWidgetIds
        case analyticsDebugMode
        case rememberMyDetails
        case membershipCardsSortType
        case hasMembershipOrderChanged
        case alwaysDownloadImages
        case showBarcodeAlways
        case mostRecentAppVersion
        case hasDismissedWhatsNewView
        case isInPollRemindPeriod
        case timeToPromptPollRemindDate

        var keyValue: String {
            switch self {
            case .hasLaunchedWallet:
                return "hasLaunchedWallet"
            case .debugBaseURL:
                return "debugBaseURL"
            case .webScrapingCookies(let membershipCardId):
                return "webScrapingCookies_cardId_\(membershipCardId)"
            case .responseCodeVisualiser:
                return "responseCodeVisualiser"
            case .inAppReviewLastRequestedDate:
                return "inAppReviewLastRequestedDate"
            case .inAppReviewRequestedMinorVersions:
                return "inAppReviewRequestedMinorVersions"
            case .applyInAppReviewRules:
                return "applyInAppReviewRules"
            case .allowCustomBundleClientOnLogin:
                return "allowCustomBundleClientOnLogin"
            case .membershipCardMostRecentTransaction(let cardId):
                return "membership_card_most_recent_transaction_\(cardId)"
            case .appLaunches:
                return "appLaunches"
            case .hasPreviouslyLaunchedApp:
                return "hasPreviouslyLaunchedApp"
            case .localWalletOrder(let userId, let walletType):
                return "localWalletOrders_user_\(userId)_\(walletType.rawValue)"
            case .theme:
                return "theme"
            case .featureFlags:
                return "featureFlags"
            case .skippedRecommendedVersions:
                return "skippedRecommendedVersions"
            case .lpcDebugMode:
                return "lpcDebugMode"
            case .hasCurrentUser:
                return "hasCurrentUser"
            case .installedWidgetIds:
                return "installedWidgetIds"
            case .analyticsDebugMode:
                return "analyticsDebugMode"
            case .rememberMyDetails:
                return "rememberMyDetails"
            case .membershipCardsSortType:
                return "membershipCardsSortType"
            case .hasMembershipOrderChanged:
                return "hasMembershipOrderChanged"
            case .alwaysDownloadImages:
                return "alwaysDownloadImages"
            case .showBarcodeAlways:
                return "showBarcodeAlways"
            case .mostRecentAppVersion:
                return "mostRecentAppVersion"
            case .hasDismissedWhatsNewView:
                return "hasDismissedWhatsNewView"
            case .isInPollRemindPeriod:
                return "isInPollRemindPeriod"
            case .timeToPromptPollRemindDate:
                return "timeToPromptPollRemindDate"
            }
        }
    }

    func set(_ value: Any?, forDefaultsKey defaultName: UserDefaults.Keys) {
        set(value, forKey: defaultName.keyValue)
    }

    func string(forDefaultsKey defaultName: UserDefaults.Keys) -> String? {
        return string(forKey: defaultName.keyValue)
    }

    func bool(forDefaultsKey defaultName: UserDefaults.Keys) -> Bool {
        return bool(forKey: defaultName.keyValue)
    }

    func value(forDefaultsKey defaultName: UserDefaults.Keys) -> Any? {
        return value(forKey: defaultName.keyValue)
    }
}
