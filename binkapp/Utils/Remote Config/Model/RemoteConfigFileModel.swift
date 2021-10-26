//
//  RemoteConfigFileModel.swift
//  binkapp
//
//  Created by Nick Farrant on 28/09/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import Foundation

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
        let idleThreshold: Int?
        let idleRetryLimit: Int?
        let agents: [Agent]?
        
        enum CodingKeys: String, CodingKey {
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
        let features: [BetaFeature]?
        let users: [BetaUser]?
    }
}
