//
//  FeatureSetModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

struct FeatureSetModel : Codable {
    let authorisationRequired : Bool?
    let transactionsAvailable : Bool?
    let digitalOnly : Bool?
    let linkingSupport : [String]?
    let hasPoints : Bool?
    let cardType : Int?
    let apps : [String]?
}
