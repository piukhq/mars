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

enum ZendeskService {
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
        /// Forces fetch of requests and enables realtime update of unread messages
        provider.getAllRequests { (req, _) in
            provider.getUpdatesForDevice { requestUpdates in
                Current.userDefaults.set(requestUpdates?.hasUpdatedRequests(), forDefaultsKey: .hasSupportUpdates)
                completion(requestUpdates?.hasUpdatedRequests() == true)
            }
        }
    }

    private static func setIdentity(fullName: String?) {
        let identity = Identity.createAnonymous(name: fullName, email: Current.userManager.currentEmailAddress)
        Zendesk.instance?.setIdentity(identity)
    }
    
    static var pendingPaymentCardsArticleID: String {
        return APIConstants.isProduction ? "360016688220" : "360016721639"
    }

    static func makeFAQViewController() -> UIViewController {
        let helpCenterConfig = HelpCenterUiConfiguration()
        helpCenterConfig.showContactOptions = false
        let articleConfig = ArticleUiConfiguration()
        articleConfig.showContactOptions = false
        return ZDKHelpCenterUi.buildHelpCenterArticleUi(withArticleId: ZendeskService.pendingPaymentCardsArticleID, andConfigs: [helpCenterConfig, articleConfig])
    }
}
