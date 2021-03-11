//
//  BinkLoggerErrors.swift
//  binkapp
//
//  Created by Sean Williams on 11/03/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import Foundation

enum PaymentCardLoggerError: String, BinkLoggerProtocol {
    case addPaymentCardFailure = "Add payment card failure"
    case deletePaymentCardFailure = "Delete payment card failure"
    case spreedlyTokenResponseFailure = "Spreedly response failure"
    case pllLoyaltyCardLinkingFailure = "PLL loyalty card linking failure"
    case pllLoyaltyCardUnlinkingFailure = "PLL loyalty card unlinking failure"
    case fetchPaymentCards = "Problem fetching payment cards"
    case fetchPaymentCard = "Problem fetching payment card"
    
    var category: BinkLoggerCategory {
        return .paymentCards
    }
    
    var message: String {
        return rawValue
    }
}

enum LoyaltyCardLoggerError: String, BinkLoggerProtocol {
    case addLoyaltyCardFailure = "Add loyalty card failure"
    case deleteLoyaltyCardFailure = "Delete loyalty card failure"
    case fetchMembershipCards = "Problem fetching membership cards"

    var category: BinkLoggerCategory {
        return .loyaltyCards
    }
    
    var message: String {
        return rawValue
    }
}

enum WalletLoggerError: String, BinkLoggerProtocol {
    case addGhostCardFailure = "Add ghost card failure"
    case updateGhostCardFailure = "Update ghost card failure"
    case fetchMembershipPlans = "Problem fetching membership plans"
    case pointsScrapingFailure = "Failed points scraping"

    var category: BinkLoggerCategory {
        return .wallet
    }
    
    var message: String {
        return rawValue
    }
}

enum AppLoggerError: String, BinkLoggerProtocol {
    case coreDataObjectMappingFailure = "Could not map object"
    case lockDeviceForAVCaptureConfig = "Could not aquire device lock for AV capture configuration"
    case unsupportedViewController = "Unsupported view controller for presentation"
    case stringEncryption = "Sensitive field string encryption failure"
    case retrieveKeychainValueFromKey = "Problem fetching keychain value from key"
    case remoteConfigFetchFailure = "Failed to fetch remote config data"
    case barcodeScanningFailure = "Incorrect barcode scanned"

    
    var category: BinkLoggerCategory {
        return .app
    }
    
    var message: String {
        return rawValue
    }
}

enum UserLoggerError: String, BinkLoggerProtocol {
    case appleSignIn = "Apple sign in auth failure"
    case updatePreferences = "Preferences update failure"
    case setNewUser = "Problem setting new user"
    case fetchUserProfile = "Failed to fetch user profile"
    case updateUserProfileFailure = "Failed to update user profile"
    case userLogoutFailure = "Failed to log user out"
    case forgotPasswordRequestFailure = "Forgot password request submission failure"
    case userRegistrationFailure = "Failed to register user"
    case userLoginFailure = "Failed to login"
    case facebookAuthFailure = "Failed to authorise user with Facebook"
    case createServiceFailure = "Failed to create service"
    case fetchPreferencesFailure = "Failed to fetch preferences"
    case setPreferencesFailure = "Failed to set preferences"
    case renewTokenFailure = "Failed to renew token"
    
    var category: BinkLoggerCategory {
        return .user
    }
    
    var message: String {
        return rawValue
    }
}
