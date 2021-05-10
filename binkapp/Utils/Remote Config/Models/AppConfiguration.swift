//
//  AppConfiguration.swift
//  binkapp
//
//  Created by Nick Farrant on 10/05/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import Foundation

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
