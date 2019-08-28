//
//  PlanDocumentModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

struct PlanDocumentModel : Codable {
    let name : String?
    let description : String?
    let url : String?
    let display : [String]?
    let checkbox : Bool?
}
