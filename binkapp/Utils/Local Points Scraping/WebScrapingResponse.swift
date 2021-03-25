//
//  WebScrapingResponse.swift
//  binkapp
//
//  Created by Nick Farrant on 03/02/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import Foundation

struct WebScrapingResponse: Codable {
    var pointsString: String?
    var errorMessage: String?

    var pointsValue: Int? {
        guard let string = pointsString else { return nil }
        return Int(string)
    }

    enum CodingKeys: String, CodingKey {
        case pointsString = "points"
        case errorMessage = "error_message"
    }
}
