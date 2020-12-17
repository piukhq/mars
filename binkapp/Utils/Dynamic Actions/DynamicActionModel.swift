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
    let startDate: Double?
    let endDate: Double?
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

    var isActive: Bool {
        return true
//        guard let startDate = startDate else { return false }
//        guard let endDate = endDate else { return false }
//        let start = Date(timeIntervalSince1970: startDate)
//        let end = Date(timeIntervalSince1970: endDate)
//        let now = Date()
//        return start < now && end > now
    }

    func location(for viewController: BinkViewController) -> DynamicActionLocation? {
        // LOL - Had to use Swift.type(of:) otherwise Xcode thought I was refering to the `type` property in DynamicAction
        // 👏 Swift compiler, great job.
        return locations?.first(where: { $0.screen?.viewControllerType == Swift.type(of: viewController) })
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

    var viewControllerType: BinkViewController.Type {
        switch self {
        case .loyaltyWallet:
            return LoyaltyWalletViewController.self
        case .paymentWallet:
            return PaymentWalletViewController.self
        }
    }
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
