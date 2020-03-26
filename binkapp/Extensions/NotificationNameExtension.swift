//
//  NotificationNameExtension.swift
//  binkapp
//
//  Created by Paul Tiriteu on 09/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let noInternetConnection = Notification.Name("no_internet_connection")
    static let shouldLogout = Notification.Name("should_logout")

    // MARK: - Wallet
    static let didLoadWallet = Notification.Name("did_download_wallets")
    static let didLoadLocalWallet = Notification.Name("did_load_local_wallets")
    static let didAddPaymentCard = Notification.Name("did_add_payment_card")
    static let didDeleteMemebershipCard = Notification.Name("did_delete_membership_card")
    static let didAddMembershipCard = Notification.Name("did_add_membership_card")
    static let shouldTrashLocalWallets = Notification.Name("should_trash_local_wallets")

    // MARK: - SSL Pinning
    static let didFailServerTrustEvaluation = Notification.Name("did_fail_server_trust_evaluation")
    
    //MARK: - Server Errors
    static let outageError = Notification.Name("outage_error")
    static let outageSilentFail = Notification.Name("outage_silent_fail")
    static let logoutOutage = Notification.Name("logout_outage")
}
