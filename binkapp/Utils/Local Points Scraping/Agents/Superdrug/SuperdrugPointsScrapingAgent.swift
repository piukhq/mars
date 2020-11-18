//
//  SuperdrugPointsScrapingAgent.swift
//  binkapp
//
//  Created by Nick Farrant on 16/11/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import Foundation
import SwiftSoup

struct SuperdrugScrapingAgent: WebScrapable {
    var merchant: WebScrapableMerchant {
        return .superdrug
    }

    var membershipPlanId: Int {
        switch APIConstants.currentEnvironment {
        case .dev:
            return 16
        case .staging:
            return 16
        case .preprod:
            return 16
        case .production:
            return 16
        }
    }

    var usernameFieldTitle: String {
        return "Email address"
    }

    var passwordFieldTitle: String {
        return "Password"
    }

    var loyaltySchemeBalanceCurrency: String? {
        return nil
    }

    var loyaltySchemeBalancePrefix: String? {
        return nil
    }

    var loyaltySchemeBalanceSuffix: String? {
        return "points"
    }

    var loginUrlString: String {
        return "https://www.superdrug.com/login"
    }

    var scrapableUrlString: String {
        return "https://www.superdrug.com/login"
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
        return try? SwiftSoup.parse(html).select("b").last()?.text()
    }
}
