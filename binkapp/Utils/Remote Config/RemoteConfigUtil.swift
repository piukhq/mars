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
        case inAppReviewEnabled
        case dynamicActions
        case betaFeatures
        case betaUsers
        case appConfiguration
        case configFile
        
        var formattedKey: String {
            switch self {
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
            case .configFile:
                return "config_file"
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
    
    var configFile: RemoteConfigFile? {
        return objectForConfigKey(.configFile, forObjectType: RemoteConfigFile.self)
    }
    
    private func setupRemoteConfig() {
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        remoteConfig.configSettings = settings
    }
    
    func handleRemoteConfigFetch() {
        hasPerformedFetch = true
        Current.featureManager.getFeaturesFromRemoteConfig()
        appConfiguration.promptRecommendedUpdateIfNecessary()
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
    
    func boolValueForConfigKey(_ configKey: RemoteConfigKey) -> Bool {
        return remoteConfig.configValue(forKey: configKey.formattedKey).boolValue
    }

    func objectForConfigKey<T: Codable>(_ configKey: RemoteConfigKey, forObjectType objectType: T.Type) -> T? {
        return remoteConfig.configValue(forKey: configKey.formattedKey).stringValue?.asDecodedObject(ofType: objectType)
    }
}

struct RemoteConfigFile: Codable {
    let localPointsCollection: LocalPointsCollection?
    let appConfig: AppConfig?
    let dynamicActions: [DynamicAction]?
    let beta: Beta?
    
    enum CodingKeys: String, CodingKey {
        case localPointsCollection = "local_points_collection"
        case appConfig = "app_config"
        case dynamicActions = "dynamic_actions"
        case beta
    }
    
    struct LocalPointsCollection: Codable {
        let enabled: Bool?
        let idleThreshold: Int?
        let idleRetryLimit: Int?
        let agents: [Agent]?
        
        enum CodingKeys: String, CodingKey {
            case enabled
            case idleThreshold = "idle_threshold"
            case idleRetryLimit = "idle_retry_limit"
            case agents
        }
        
        struct Agent: Codable {
            let merchant: LocalPointsCollectableMerchant?
            let membershipPlanIds: MembershipPlanId?
            let enabled: Enabled?
            let loyaltyScheme: LoyaltyScheme?
            let pointsCollectionUrlString: String?
            let fields: Fields?
            let scriptFileName: String?
            
            var membershipPlanId: Int? {
                switch APIConstants.currentEnvironment {
                case .dev:
                    return membershipPlanIds?.dev
                case .staging:
                    return membershipPlanIds?.staging
                case .preprod:
                    return membershipPlanIds?.preprod
                case .production:
                    return membershipPlanIds?.production
                }
            }
            
            enum CodingKeys: String, CodingKey {
                case merchant
                case membershipPlanIds = "membership_plan_id"
                case enabled
                case loyaltyScheme = "loyalty_scheme"
                case pointsCollectionUrlString = "points_collection_url"
                case fields
                case scriptFileName = "script_file_name"
            }
            
            struct MembershipPlanId: Codable {
                let dev: Int?
                let staging: Int?
                let preprod: Int?
                let production: Int?
            }
            
            struct Enabled: Codable {
                let ios: Bool?
                let iosDebug: Bool?
                let android: Bool?
                let androidDebug: Bool?
                
                enum CodingKeys: String, CodingKey {
                    case ios
                    case iosDebug = "ios_debug"
                    case android
                    case androidDebug = "android_debug"
                }
            }
            
            struct LoyaltyScheme: Codable {
                let balanceCurrency: String?
                let balancePrefix: String?
                let balanceSuffix: String?
                
                enum CodingKeys: String, CodingKey {
                    case balanceCurrency = "balance_currency"
                    case balancePrefix = "balance_prefix"
                    case balanceSuffix = "balance_suffix"
                }
            }
            
            struct Fields: Codable {
                let usernameFieldCommonName: FieldCommonName?
                let requiredCredentials: [PointsScrapingManager.CredentialStoreType]?
                let authFields: [AuthoriseFieldModel]?
                let scriptFileName: String?
                
                enum CodingKeys: String, CodingKey {
                    case usernameFieldCommonName = "username_field_common_name"
                    case requiredCredentials = "required_credentials"
                    case authFields = "auth_fields"
                    case scriptFileName = "script_file_name"
                }
            }
        }
    }
    
    struct AppConfig: Codable {
        let inAppReviewEnabled: Bool?
        let recommendedLiveAppVersion: RecommendedLiveAppVersion?
        
        enum CodingKeys: String, CodingKey {
            case inAppReviewEnabled = "in_app_review_enabled"
            case recommendedLiveAppVersion = "recommended_live_app_version"
        }
        
        struct RecommendedLiveAppVersion: Codable {
            let ios: String?
            let android: String?
        }
    }
    
    struct Beta: Codable {
        let features: [Feature]?
        let users: [User]?
        
        struct Feature: Codable {
            let slug: String?
            let type: String?
            let title: String?
            let description: String?
            let enabled: Bool?
        }
        
        struct User: Codable {
            let uid: String?
        }
    }
}
