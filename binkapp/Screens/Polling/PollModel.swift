//
//  PollModel.swift
//  binkapp
//
//  Created by Ricardo Silva on 28/03/2023.
//  Copyright © 2023 Bink. All rights reserved.
//

import Foundation
import FirebaseFirestoreSwift

enum PollStatus: Int, Codable {
    case draft = 0
    case published = 1
    case closed = 2
}

struct PollModel: Codable {
    var id: String
    var title: String
    var answers: [String]
    var startTime: Int
    var closeTime: Int
    var publishedStatus: PollStatus
    var question: String
}
