//
//  AccountPostModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

struct AccountPostModel: Codable {
    var addFields: [AddFieldPostModel] = []
    var authoriseFields: [AuthoriseFieldPostModel] = []
    var enrolFields: [EnrolFieldPostModel] = []
    var registrationFields: [RegistrationFieldPostModel] = []
    
    enum CodingKeys: String, CodingKey {
        case addFields = "add_fields"
        case authoriseFields = "authorise_fields"
        case enrolFields = "enrol_fields"
        case registrationFields = "registration_fields"
    }
}

