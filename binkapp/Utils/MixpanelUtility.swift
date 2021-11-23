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
            #if RELEASE
                mixpanelInstance = Mixpanel.initialize(token: BinkappKeys().mixpanelTokenProduction, flushInterval: 60, instanceName: "prod", optOutTrackingByDefault: false)
                Mixpanel.setMainInstance(name: "prod")
            #endif
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
    
    static func setUserProperties() {
        setUserProperties([
            .widget(true)
        ])
    }
    
    static func setUserProperties(_ properties: [MixpanelUserProperty]) {
//        mixpanelInstance.people.set(properties: properties)
    }
}

enum MixpanelTrackableEvent {
    case loyaltyCardAdd(brandName: String?)
    case loyaltyCardAddFailure(brandName: String, reason: String?)
    case lcdViewed(brandName: String)
    case loyaltyCardManuallyReordered(brandName: String, originalIndex: Int, destinationIndex: Int)
    case localPointsCollectionSuccess(brandName: String)
    case localPointsCollectionStatus(membershipCard: CD_MembershipCard)
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
        case .loyaltyCardManuallyReordered:
            return "Loyalty card manually reordered"
        case .localPointsCollectionSuccess:
            return "Local points collection succeeded"
        case .localPointsCollectionStatus:
            return "Local points collection status"
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
        case .loyaltyCardManuallyReordered(let brandName, let originalIndex, let destinationIndex):
            return [
                "Brand name": brandName,
                "Original index": originalIndex,
                "Destination index": destinationIndex
            ]
        case .localPointsCollectionSuccess(let brandName):
            return ["Brand name": brandName]
        case .localPointsCollectionStatus(let membershipCard):
            guard let planIdString = membershipCard.membershipPlan?.id, let planId = Int(planIdString) else { return nil }
            guard let id = membershipCard.id else { return nil }
            guard let status = membershipCard.status?.status?.rawValue else { return nil }
            return [
                "Loyalty plan": planId,
                "Status": status,
                "Client account id": id
            ]
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
