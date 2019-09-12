//
//  MembershipPlanAccountModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import CoreData

struct MembershipPlanAccountModel: Codable {
    let id: Int?
    let planName: String?
    let planNameCard: String?
    let planURL: String?
    let companyName: String?
    let category: String?
    let planSummary: String?
    let planDescription: String?
    let barcodeRedeemInstructions: String?
    let planRegisterInfo: String?
    let companyURL: String?
    let enrolIncentive: String?
    let forgottenPasswordUrl: String?
    let tiers: [TierModel]?
    let planDocuments: [PlanDocumentModel]?
    let addFields: [AddFieldModel]?
    let authoriseFields: [AuthoriseFieldModel]?
    let registrationFields: [RegistrationFieldModel]?
    let enrolFields: [EnrolFieldModel]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case planName = "plan_name"
        case planNameCard = "plan_name_card"
        case planURL = "plan_url"
        case companyName = "company_name"
        case category
        case planSummary = "plan_summary"
        case planDescription = "plan_description"
        case barcodeRedeemInstructions = "barcode_redeem_instructions"
        case planRegisterInfo = "plan_register_info"
        case companyURL = "company_url"
        case enrolIncentive = "enrol_incentive"
        case forgottenPasswordUrl = "forgotten_password_url"
        case tiers
        case planDocuments = "plan_documents"
        case addFields = "add_fields"
        case authoriseFields = "authorise_fields"
        case registrationFields = "registration_fields"
        case enrolFields = "enrol_fields"
    }
}

extension MembershipPlanAccountModel: CoreDataMappable {
    func objectToMapTo(_ cdObject: CD_MembershipPlanAccount, in context: NSManagedObjectContext, delta: Bool, overrideID: Int?) -> CD_MembershipPlanAccount {
        // Our codable models all need to have id's as Int's as dictated by API responses
        // However, we want to cast these all to strings so that our core data wrapper remains unchanged.
        let idString = String(id ?? 0)

        update(cdObject, \.id, with: idString, delta: delta)
        update(cdObject, \.planName, with: planName, delta: delta)
        update(cdObject, \.planNameCard, with: planNameCard, delta: delta)
        update(cdObject, \.planURL, with: planURL, delta: delta)
        update(cdObject, \.companyName, with: companyName, delta: delta)
        update(cdObject, \.category, with: category, delta: delta)
        update(cdObject, \.planSummary, with: planSummary, delta: delta)
        update(cdObject, \.planDescription, with: planDescription, delta: delta)
        update(cdObject, \.barcodeRedeemInstructions, with: barcodeRedeemInstructions, delta: delta)
        update(cdObject, \.planRegisterInfo, with: planRegisterInfo, delta: delta)
        update(cdObject, \.companyURL, with: companyURL, delta: delta)
        update(cdObject, \.enrolIncentive, with: enrolIncentive, delta: delta)
        update(cdObject, \.forgottenPasswordUrl, with: forgottenPasswordUrl, delta: delta)

        return cdObject
    }
}
