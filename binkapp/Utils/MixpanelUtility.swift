//
//  MixpanelUtility.swift
//  
//
//  Created by Nick Farrant on 12/10/2021.
//

import Foundation
import Mixpanel
import Keys

enum MixpanelUtility {
    private static var mixpanelInstance: MixpanelInstance?
    
    static func configure() {
        if Current.userDefaults.bool(forDefaultsKey: .analyticsDebugMode) {
            Mixpanel.removeInstance(name: "prod")
            mixpanelInstance = Mixpanel.initialize(token: BinkappKeys().mixpanelTokenDev, flushInterval: 60, instanceName: "dev", optOutTrackingByDefault: false)
            Mixpanel.setMainInstance(name: "dev")
        } else {
            Mixpanel.removeInstance(name: "dev")
            mixpanelInstance = nil
            
            if !Configuration.isDebug() {
                mixpanelInstance = Mixpanel.initialize(token: BinkappKeys().mixpanelTokenProduction, flushInterval: 60, instanceName: "prod", optOutTrackingByDefault: false)
                Mixpanel.setMainInstance(name: "prod")
            }
        }
    }
    
    static func startTimer(for event: MixpanelTrackableEvent) {
        mixpanelInstance?.time(event: event.identifier)
    }
    
    static func track(_ event: MixpanelTrackableEvent) {
        mixpanelInstance?.track(event: event.identifier, properties: event.data)
    }
    
    static func setUserIdentity(userId: String) {
        mixpanelInstance?.identify(distinctId: userId)
    }
    
    static func resetUserIdentity() {
        mixpanelInstance?.reset()
    }
    
    static func setUserProperty(_ userProperty: MixpanelUserProperty) {
        mixpanelInstance?.people.set(properties: userProperty.data)
    }
}

enum MixpanelTrackableEvent {
    case loyaltyCardAdd(brandName: String)
    case loyaltyCardAddFailure(brandName: String, reason: String?)
    case loyaltyCardDeleted(brandName: String, route: JourneyRoute)
    case lcdViewed(brandName: String, route: JourneyRoute)
    case loyaltyCardManuallyReordered(brandName: String, originalIndex: Int, destinationIndex: Int)
    case localPointsCollectionSuccess(brandName: String)
    case localPointsCollectionFailure(brandName: String, reason: String?, underlyingError: String?)
    case onboardingStart(route: LoginType)
    case onboardingComplete(route: LoginType)
    case onboardingCarouselSwipe
    case forgottenPassword
    case logout
    case viewBarcode(brandName: String, route: JourneyRoute)
    case barcodeScreenIssueReported(brandName: String, reason: BarcodeScreenIssue)
    case toLocations(brandName: String)
    case toAppleMaps(brandName: String)
    
    enum JourneyRoute: String {
        case wallet = "Wallet"
        case lcd = "Loyalty Card Detail"
        case quickLaunchWidget = "Quick Launch Widget"
    }
    
    var identifier: String {
        switch self {
        case .loyaltyCardAdd:
            return "Loyalty card add"
        case .loyaltyCardAddFailure:
            return "Loyalty card add failed"
        case .loyaltyCardDeleted:
            return "Loyalty card deleted"
        case .lcdViewed:
            return "Loyalty card detail viewed"
        case .loyaltyCardManuallyReordered:
            return "Loyalty card manually reordered"
        case .localPointsCollectionSuccess:
            return "Local points collection succeeded"
        case .localPointsCollectionFailure:
            return "Local points collection failed"
        case .onboardingStart:
            return "Onboarding start"
        case .onboardingComplete:
            return "Onboarding complete"
        case .onboardingCarouselSwipe:
            return "Onboarding carousel swipe"
        case .forgottenPassword:
            return "Forgotten password"
        case .logout:
            return "User logged out"
        case .viewBarcode:
            return "Barcode viewed"
        case .barcodeScreenIssueReported:
            return "Barcode screen issue reported"
        case .toLocations:
            return "Tapped Show Locations"
        case .toAppleMaps:
            return "Launch Apple Maps for Directions"
        }
    }
    
    var data: [String: MixpanelType]? {
        switch self {
        case .loyaltyCardAdd(let brandName):
            return ["Brand name": brandName]
        case .loyaltyCardAddFailure(let brandName, let reason):
            return [
                "Brand name": brandName,
                "Reason": reason ?? "Unknown"
            ]
        case .loyaltyCardDeleted(let brandName, let route):
            return [
                "Brand name": brandName,
                "Route": route.rawValue
            ]
        case .lcdViewed(let brandName, let route):
            return [
                "Brand name": brandName,
                "Route": route.rawValue
            ]
        case .loyaltyCardManuallyReordered(let brandName, let originalIndex, let destinationIndex):
            return [
                "Brand name": brandName,
                "Original index": originalIndex,
                "Destination index": destinationIndex
            ]
        case .localPointsCollectionSuccess(let brandName):
            return ["Brand name": brandName]
        case .localPointsCollectionFailure(let brandName, let reason, let error):
            return [
                "Brand name": brandName,
                "Reason": reason ?? "Unknown",
                "Underlying error": error
            ]
        case .onboardingStart(let route):
            return ["Route": route.rawValue]
        case .onboardingComplete(let route):
            return ["Route": route.rawValue]
        case .viewBarcode(let brandName, let route):
            return [
                "Brand name": brandName,
                "Route": route.rawValue
            ]
        case .logout, .onboardingCarouselSwipe, .forgottenPassword:
            return [:]
        case .barcodeScreenIssueReported(brandName: let brandName, let reason):
            return [
                "Reason": reason.rawValue,
                "Brand name": brandName
            ]
        case .toLocations(brandName: let brandName):
            return ["Brand": brandName]
        case .toAppleMaps(brandName: let brandName):
            return ["Brand": brandName]
        }
    }
}

enum MixpanelUserProperty {
    case appleWatchInstalled(Bool)
    case totalLoyaltyCards(Int)
    case totalPLLCards(Int)
    case activePLLCards(Int)
    case localPointsCollectionCards
    case widget(Bool)
    case loyaltyCards
    case lastEngaged(Int)
    case loyaltyCardsSortOrder(String)
    
    var identifer: String {
        switch self {
        case .appleWatchInstalled:
            return "Apple Watch Installed"
        case .totalLoyaltyCards:
            return "Total number of loyalty cards"
        case .totalPLLCards:
            return "Total number of PLL cards"
        case .activePLLCards:
            return "Total number of active PLL cards"
        case .localPointsCollectionCards:
            return "Local points collection cards"
        case .widget:
            return "Has widget installed"
        case .loyaltyCards:
            return "Loyalty cards"
        case .lastEngaged:
            return "Last engaged"
        case .loyaltyCardsSortOrder:
            return "Wallet Sort Setting"
        }
    }
    
    var data: [String: MixpanelType] {
        switch self {
        case.appleWatchInstalled(let isInstalled):
            return [identifer: isInstalled]
        case.loyaltyCardsSortOrder(let value):
            return [identifer: value]
        default:
            return ["": ""]
        }
    }
}
