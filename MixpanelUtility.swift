//
//  MixpanelUtility.swift
//  
//
//  Created by Nick Farrant on 12/10/2021.
//

import Foundation
import Mixpanel
import Keys

struct MixpanelUtility {
    private static let mixpanelInstance = Mixpanel.mainInstance()
    
    static func start() {
        Mixpanel.initialize(token: BinkappKeys().mixpanelToken)
    }
    
    static func startTimer(for event: MixpanelTrackableEvent) {
        mixpanelInstance.time(event: event.identifier)
    }
    
    static func track(_ event: MixpanelTrackableEvent) {
        mixpanelInstance.track(event: event.identifier, properties: event.data)
    }
    
    static func setUserIdentity(userId: String) {
        mixpanelInstance.identify(distinctId: userId)
    }
    
    static func setUserProperties() {
        setUserProperties([
            .widget(true)
        ])
    }
    
    static func setUserProperties(_ properties: [MixpanelUserProperty]) {
        //
    }
}

enum MixpanelTrackableEvent {
    case loyaltyCardAdd(brandName: String?)
    case loyaltyCardAddFailure(brandName: String, reason: String?)
    case lcdViewed(brandName: String)
    case cardsManuallyReordered
    case localPointsCollectionSuccess(brandName: String)
    case localPointsCollectionFailure(brandName: String, reason: String?)
    case login(method: LoginType)
    case logout
    
    var identifier: String {
        switch self {
        case .loyaltyCardAdd:
            return "Loyalty card add"
        case .loyaltyCardAddFailure:
            return "Loyalty card add failed"
        case .lcdViewed:
            return "Loyalty card detail viewed"
        case .cardsManuallyReordered:
            return "Cards manually reordered"
        case .localPointsCollectionSuccess:
            return "Local points collection succeeded"
        case .localPointsCollectionFailure:
            return "Local points collection failed"
        case .login:
            return "User logged in"
        case .logout:
            return "User logged out"
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
        case .lcdViewed(let brandName):
            return ["Brand name": brandName]
        case .localPointsCollectionSuccess(let brandName):
            return ["Brand name": brandName]
        case .localPointsCollectionFailure(let brandName, let reason):
            return [
                "Brand name": brandName,
                "Reason": reason ?? "Unknown"
            ]
        case .login(let method):
            return ["Method": method.rawValue]
        default: return nil
        }
    }
}

enum MixpanelUserProperty {
    case totalLoyaltyCards(Int)
    case totalPLLCards(Int)
    case activePLLCards(Int)
    case localPointsCollectionCards
    case widget(Bool)
    case loyaltyCards
    case lastEngaged(Int)
    
    var identifer: String {
        switch self {
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
        }
    }
    
    var data: [String: MixpanelType] {
        return ["": ""]
    }
}
