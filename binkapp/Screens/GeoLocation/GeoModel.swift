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

struct OpenHours: Codable {
    let Mon: [[String]]
    let Tue: [[String]]
    let Wed: [[String]]
    let Thu: [[String]]
    let Fri: [[String]]
    let Sat: [[String]]
    let Sun: [[String]]
}

struct Properties: Codable {
    let locationName: String?
    let latitude: String?
    let longitude: String?
    let streetAddress: String?
    let city: String?
    let region: String?
    let postalCode: String?
    let phoneNumber: String?
    let openHours: String?
    
    enum CodingKeys: String, CodingKey {
        case locationName = "location_name"
        case latitude
        case longitude
        case streetAddress = "street_address"
        case city
        case region
        case postalCode = "postal_code"
        case phoneNumber = "phone_number"
        case openHours = "open_hours"
    }
}
