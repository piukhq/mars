//
//  MembershipPlanAccountModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

struct MemebershipPlanAccountModel: Codable {
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
        case planName = "plan_name"
        case planNameCard = "plan_name_card"
        case planURL = "plan_url"
        case companyName = "company_name"
        case category = "category"
        case planSummary = "plan_summary"
        case planDescription = "plan_description"
        case barcodeRedeemInstructions = "barcode_redeem_instructions"
        case planRegisterInfo = "plan_register_info"
        case companyURL = "company_url"
        case enrolIncentive = "enrol_incentive"
        case forgottenPasswordUrl = "forgotten_password_url"
        case tiers = "tiers"
        case planDocuments = "plan_documents"
        case addFields = "add_fields"
        case authoriseFields = "authorise_fields"
        case registrationFields = "registration_fields"
        case enrolFields = "enrol_fields"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        planName = try values.decodeIfPresent(String.self, forKey: .planName)
        planNameCard = try values.decodeIfPresent(String.self, forKey: .planNameCard)
        planURL = try values.decodeIfPresent(String.self, forKey: .planURL)
        companyName = try values.decodeIfPresent(String.self, forKey: .companyName)
        category = try values.decodeIfPresent(String.self, forKey: .category)
        planSummary = try values.decodeIfPresent(String.self, forKey: .planSummary)
        planDescription = try values.decodeIfPresent(String.self, forKey: .planDescription)
        barcodeRedeemInstructions = try values.decodeIfPresent(String.self, forKey: .barcodeRedeemInstructions)
        planRegisterInfo = try values.decodeIfPresent(String.self, forKey: .planRegisterInfo)
        companyURL = try values.decodeIfPresent(String.self, forKey: .companyURL)
        enrolIncentive = try values.decodeIfPresent(String.self, forKey: .enrolIncentive)
        forgottenPasswordUrl = try values.decodeIfPresent(String.self, forKey: .forgottenPasswordUrl)
        tiers = try values.decodeIfPresent([TierModel].self, forKey: .tiers)
        planDocuments = try values.decodeIfPresent([PlanDocumentModel].self, forKey: .planDocuments)
        addFields = try values.decodeIfPresent([AddFieldModel].self, forKey: .addFields)
        authoriseFields = try values.decodeIfPresent([AuthoriseFieldModel].self, forKey: .authoriseFields)
        registrationFields = try values.decodeIfPresent([RegistrationFieldModel].self, forKey: .registrationFields)
        enrolFields = try values.decodeIfPresent([EnrolFieldModel].self, forKey: .enrolFields)
    }
}
