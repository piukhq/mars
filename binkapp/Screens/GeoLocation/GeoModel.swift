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
    let mon: [[String]]
    let tue: [[String]]
    let wed: [[String]]
    let thu: [[String]]
    let fri: [[String]]
    let sat: [[String]]
    let sun: [[String]]
    
    enum CodingKeys: String, CodingKey {
        case mon = "Mon"
        case tue = "Tue"
        case wed = "Wed"
        case thu = "Thu"
        case fri = "Fri"
        case sat = "Sat"
        case sun = "Sun"
    }
    
    var weeklyHours: [[String]] {
        return [sun, mon, tue, wed, thu, fri, sat, sun].map { Array($0.joined()) }
    }
    
    func openingHours(for day: Int) -> OpeningTimes? {
        guard !weeklyHours[day].isEmpty else { return nil }
        return OpeningTimes(opening: weeklyHours[day][0], closing: weeklyHours[day][1])
    }
}

struct OpeningTimes {
    let opening: String
    let closing: String
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
