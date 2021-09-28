//
//  LocalPointsCollectable.swift
//  binkapp
//
//  Created by Nick Farrant on 03/02/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import Foundation

enum LocalPointsCollectableMerchant: String, Codable {
    case tesco
    case boots
    case morrisons
    case superdrug
    case waterstones
    case heathrow
    case perfumeshop
    case starbucks
    case subway
}

typealias LocalPointsCollectable = RemoteConfigFile.LocalPointsCollection.Agent
