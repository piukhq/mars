//
//  DynamicActions.swift
//  binkapp
//
//  Created by Nick Farrant on 25/11/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import Foundation

struct DynamicAction: Codable {
    let name: String?
    let type: DynamicActionType?
    let startDate: Int?
    let endDate: Int?
    let locations: [DynamicActionLocation]?
    let event: DynamicActionEvent?

    enum CodingKeys: String, CodingKey {
        case name
        case type
        case startDate = "start_date"
        case endDate = "end_date"
        case locations
        case event
    }
}

enum DynamicActionType: String, Codable {
    case xmas
}

struct DynamicActionLocation: Codable {
    let icon: String?
    let screen: DynamicActionScreen?
    let area: DynamicActionArea?
    let action: DynamicActionHandler?
}

enum DynamicActionScreen: String, Codable {
    case loyaltyWallet = "loyalty_wallet"
    case paymentWallet = "payment_wallet"
}

enum DynamicActionArea: String, Codable {
    case leftTopBar = "left_top_bar"
}

enum DynamicActionHandler: String, Codable {
    case singleTap = "single_tap"
}

struct DynamicActionEvent: Codable {
    let type: DynamicActionEventType?
    let body: DynamicActionEventBody?
}

enum DynamicActionEventType: String, Codable {
    case launchModal = "launch_modal"
}

struct DynamicActionEventBody: Codable {
    let title: String?
    let description: String?
    let cta: DynamicActionEventBodyCTA?
}

struct DynamicActionEventBodyCTA: Codable {
    let title: String?
    let action: DynamicActionEventBodyCTAHandler?
}

enum DynamicActionEventBodyCTAHandler: String, Codable {
    case zendeskContactUs = "zd_contact_us"
}
