//
//  WaterstonesPointsScrapingAgent.swift
//  binkapp
//
//  Created by Nick Farrant on 17/11/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import Foundation
import SwiftSoup

struct WaterstonesScrapingAgent: WebScrapable {
    var merchant: WebScrapableMerchant {
        return .waterstones
    }

    var membershipPlanId: Int {
        switch APIConstants.currentEnvironment {
        case .dev:
            return 52
        case .staging:
            return 52
        case .preprod:
            return 52
        case .production:
            return 52
        }
    }

    var usernameFieldTitle: String {
        return "email"
    }

    var passwordFieldTitle: String {
        return "password"
    }

    var loyaltySchemeBalanceCurrency: String? {
        return nil
    }

    var loyaltySchemeBalancePrefix: String? {
        return nil
    }

    var loyaltySchemeBalanceSuffix: String? {
        return "stamps"
    }

    var loginUrlString: String {
        return "https://www.waterstones.com/plus/signin"
    }

    var scrapableUrlString: String {
        return "https://www.waterstones.com/account/waterstonescard"
    }

    var reCaptchaPresentationType: WebScrapingUtility.ReCaptchaPresentationType {
        return .none
    }

    var reCaptchaPresentationFrequency: WebScrapingUtility.ReCaptchaPresentationFrequency {
        return .never
    }

    var reCaptchaMessage: String? {
        return nil
    }

    var reCaptchaTextIdentiferClass: String? {
        return nil
    }

    var incorrectCredentialsMessage: String? {
        return nil
    }

    var incorrectCredentialsTextIdentiferClass: String? {
        return nil
    }

    func pointsValueFromCustomHTMLParser(_ html: String) -> String? {
        return try? SwiftSoup.parse(html).select("strong").last()?.text().replacingOccurrences(of: " stamps", with: "")
    }
}
