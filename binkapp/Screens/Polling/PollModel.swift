//
//  PollModel.swift
//  binkapp
//
//  Created by Ricardo Silva on 28/03/2023.
//  Copyright © 2023 Bink. All rights reserved.
//

import Foundation
import FirebaseFirestoreSwift

struct PollModel: Codable {
    @DocumentID var id: String?
    var title: String
    var answers: [String]
    var startTime: Int
    var closeTime: Int
    var published: Bool
    var question: String
    var remindLaterMinutes: Int?
    var allowCustomAnswer: Bool?
}
