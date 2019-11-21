//
//  PreferencesModel.swift
//  binkapp
//
//  Created by Paul Tiriteu on 21/11/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

struct PreferencesModel: Codable {
    let isUserDefined: Bool?
    let user: Int?
    let value: String?
    let slug: String?
    let defaultValue: Bool?
    let valueType: String?
    let scheme: String?
    let label: String?
    let category: String?
}
