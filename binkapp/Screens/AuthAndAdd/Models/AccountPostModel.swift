//
//  AccountPostModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

class PostModel: Codable {
    var column: String?
    var value: String?
    
    init(column: String?, value: String?) {
        self.column = column
        self.value = value
    }
}

enum MembershipAccountPostModelType {
    case add
    case auth
    case enrol
    case registration
}

struct AccountPostModel: Codable {
    var addFields: [PostModel]?
    var authoriseFields: [PostModel]?
    var enrolFields: [PostModel]?
    var registrationFields: [PostModel]?
    
    enum CodingKeys: String, CodingKey {
        case addFields = "add_fields"
        case authoriseFields = "authorise_fields"
        case enrolFields = "enrol_fields"
        case registrationFields = "registration_fields"
    }
    
    mutating func addField(_ field: PostModel, to type: MembershipAccountPostModelType) {
                
        switch type {
        case .add:
            if addFields == nil {
                addFields = []
            }
            
            addFields?.append(field)
        case .auth:
            if authoriseFields == nil {
                authoriseFields = []
            }
            
            authoriseFields?.append(field)
        case .enrol:
            if enrolFields == nil {
                enrolFields = []
            }
            
            enrolFields?.append(field)
        case .registration:
            if registrationFields == nil {
                registrationFields = []
            }
            
            registrationFields?.append(field)
        }
    }
}

