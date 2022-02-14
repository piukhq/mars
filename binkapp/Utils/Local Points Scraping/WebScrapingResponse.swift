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
    var didAttemptLogin: Bool?
    var errorMessage: String?
    var userActionRequired: Bool?
    var userActionComplete: Bool?

    var pointsValue: Int? {
        guard var string = pointsString else { return nil }
        string = string.replacingOccurrences(of: ",", with: "")
        return Int(string)
    }

    enum CodingKeys: String, CodingKey {
        case pointsString = "points"
        case didAttemptLogin = "did_attempt_login"
        case errorMessage = "error_message"
        case userActionRequired = "user_action_required"
        case userActionComplete = "user_action_complete"
    }
}
