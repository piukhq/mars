//
//  ZendeskService.swift
//  binkapp
//
//  Created by Nick Farrant on 04/05/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import Foundation

import ZendeskCoreSDK
import SupportSDK
import Keys

final class ZendeskService {
    private static var appId: String {
        return APIConstants.isProduction ? BinkappKeys().zendeskProductionAppId : BinkappKeys().zendeskSandboxAppId
    }

    private static var clientId: String {
        return APIConstants.isProduction ? BinkappKeys().zendeskProductionClientId : BinkappKeys().zendeskSandboxClientId
    }
    
    private static var url: String {
        return APIConstants.isProduction ? BinkappKeys().zendeskProductionUrl : BinkappKeys().zendeskSandboxUrl
    }

    static var shouldPromptForIdentity: Bool {
        let firstName = Current.userManager.currentFirstName ?? ""
        let lastName = Current.userManager.currentLastName ?? ""
        return firstName.isEmpty || lastName.isEmpty
    }

    static func start() {
        Zendesk.initialize(appId: ZendeskService.appId, clientId: ZendeskService.clientId, zendeskUrl: ZendeskService.url)
        Support.initialize(withZendesk: Zendesk.instance)

        let firstName = Current.userManager.currentFirstName
        let lastName = Current.userManager.currentLastName
        setIdentity(firstName: firstName, lastName: lastName)
    }

    static func setIdentity(firstName: String?, lastName: String?) {
        guard let firstName = firstName, let lastName = lastName else {
            // If we can't set a complete identity, set it to nil
            setIdentity(fullName: nil)
            return
        }
        setIdentity(fullName: "\(firstName) \(lastName)")
    }
    
    static func getIdentityRequestUpdates(completion: @escaping (Bool) -> Void) {
        let provider = ZDKRequestProvider()
        provider.getUpdatesForDevice { requestUpdates in
            completion(requestUpdates?.hasUpdatedRequests() == true)
        }
    }

    private static func setIdentity(fullName: String?) {
        let identity = Identity.createAnonymous(name: fullName, email: Current.userManager.currentEmailAddress)
        Zendesk.instance?.setIdentity(identity)
    }
    
//    static func isTargettingProduction() -> Bool {
//        return APIConstants.isProduction
//    }
    
    static var pendingPaymentCardsArticleID: String {
        return APIConstants.isProduction ? "360016688220" : "360016721639"
    }
}
