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
    static let didDeleteMemebershipCard = Notification.Name("did_delete_membership_card")
    static let didAddMembershipCard = Notification.Name("did_add_membership_card")
}
