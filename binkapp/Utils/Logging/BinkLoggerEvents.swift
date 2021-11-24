//
//  BinkLoggerEvents.swift
//  binkapp
//
//  Created by Sean Williams on 10/03/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import Foundation

enum BinkLoggerCategory: String {
    case paymentCards = "Payment Cards"
    case loyaltyCards = "Loyalty Cards"
    case app = "App"
    case user = "User"
    case wallet = "Wallet"
}

protocol BinkLoggerProtocol {
    var category: BinkLoggerCategory { get }
    var message: String { get }
}

enum PaymentCardLoggerEvent: String, BinkLoggerProtocol {
    case paymentCardAdded = "Payment card added"
    case paymentCardDeleted = "Payment card deleted"
    case fetchedPaymentCards = "Fetched payment cards"
    case fetchedPaymentCard = "Fetched payment card"
    case spreedlyTokenResponseSuccess = "Spreedly token success"
    case pllLoyaltyCardLinked = "PLL loyalty card linked"
    case pllLoyaltyCardUnlinked = "PLL loyalty card unlinked"
    
    var category: BinkLoggerCategory {
        return .paymentCards
    }
    
    var message: String {
        return rawValue
    }
}

enum LoyaltyCardLoggerEvent: String, BinkLoggerProtocol {
    case loyaltyCardAdded = "Loyalty card added"
    case loyaltyCardDeleted = "Loyalty card deleted"
    case fetchedMembershipCards = "Fetched membership cards"

    var category: BinkLoggerCategory {
        return .loyaltyCards
    }
    
    var message: String {
        return rawValue
    }
}

enum WalletLoggerEvent: String, BinkLoggerProtocol {
    case ghostCardAdded = "Ghost card added"
    case ghostCardUpdated = "Ghost card updated"
    case pointsScrapingSuccess = "Points scraping success"
    case fetchedMembershipPlans = "Fetched membership plans"

    var category: BinkLoggerCategory {
        return .wallet
    }
    
    var message: String {
        return rawValue
    }
}

enum AppLoggerEvent: String, BinkLoggerProtocol {
    case databaseInitialised = "Database initialised at"
    case appEnteredForeground = "App entered foreground"
    case appEnteredBackground = "App entered background"
    case fetchedRemoteConfig = "Fetched remote config data"
    case requestedInAppReview = "Requested in-app review"
    case barcodeScanned = "Barcode scanned"
    case paymentCardScanned = "Payment card scanned"

    var category: BinkLoggerCategory {
        return .app
    }
    
    var message: String {
        return rawValue
    }
}

enum UserLoggerEvent: String, BinkLoggerProtocol {
    case fetchedUserProfile = "Fetched user profile"
    case updatedUserProfile = "Updated user profile"
    case logout = "User logged out successfully"
    case submittedForgotPasswordRequest = "Submitted forgot password request"
    case registeredUser = "Registered new user"
    case userLoggedIn = "User logged in"
    case signedInWithApple = "Signed in with Apple"
    case createdService = "Created service"
    case fetchedPreferences = "Fetched preferences"
    case setPreferences = "Set preferences success"
    case renewedToken = "Renewed token"
    case sentMagicLink = "Sent magic link"
    case receivedMagicLinkAccessToken = "Received magic link access token"

    var category: BinkLoggerCategory {
        return .user
    }
    
    var message: String {
        return rawValue
    }
}
