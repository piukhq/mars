//
//  MembershipPlanAccountModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

struct MemebershipPlanAccountModel : Codable {
    let planName : String?
    let planNameCard : String?
    let planURL : String?
    let companyName : String?
    let category : String?
    let planSummary : String?
    let planDescription : String?
    let barcodeRedeemInstructions : String?
    let planRegisterInfo : String?
    let companyURL : String?
    let enrolIncentive : String?
    let forgottenPasswordURL : String?
    let tiers : [TierModel]?
    let planDocuments : [PlanDocumentModel]?
    let addFields : [AddFieldModel]?
    let authoriseFields : [AuthoriseFieldModel]?
    let registrationFields : [RegistrationFieldModel]?
    let enrolFields : [EnrolFieldModel]?
}
