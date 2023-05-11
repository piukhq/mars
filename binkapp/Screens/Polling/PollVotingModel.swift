//
//  PollVotingModel.swift
//  binkapp
//
//  Created by Ricardo Silva on 28/03/2023.
//  Copyright © 2023 Bink. All rights reserved.
//

import Foundation
import FirebaseFirestoreSwift

struct PollVotingModel: Codable {
    @DocumentID var id: String?
    var pollId: String
    var userId: String
    var createdDate: Int
    var overwritten: Bool
    var answer: String
    var customAnswer: String
}
