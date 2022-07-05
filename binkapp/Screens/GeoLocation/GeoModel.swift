//
//  GeoModel.swift
//  binkapp
//
//  Created by Ricardo Silva on 05/07/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import Foundation

struct GeoModel: Codable {
    let type: String
    let features: [Feature]
}

struct Feature: Codable {
    let type: String
    let properties: Properties
    let geometry: Geometry
}

struct Geometry: Codable {
    let type: String
    let coordinates: [Double]
}

struct Properties: Codable {
    let location_name: String?
    let latitude: String?
    let longitude: String?
    let street_address: String?
    let city: String?
    let region: String?
    let postal_code: String?
    let phone_number: String?
    let open_hours: String?
}
