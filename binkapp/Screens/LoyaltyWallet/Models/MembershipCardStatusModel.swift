//
//  MembershipCardStatusModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

struct MembershipCardStatusModel: Codable {
    let state : MembershipCardStatus?
    let reasonCodes : [String]?
    
    enum MembershipCardStatus: String, Codable {
        case authorised
        case unauthorised
        case pending
        case failed 
    }
}
