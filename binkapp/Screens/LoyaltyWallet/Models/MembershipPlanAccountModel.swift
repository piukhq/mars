//
//  MembershipPlanAccountModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import CoreData

struct MembershipPlanAccountModel: Codable {
    let apiId: Int?
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
        case apiId = "id"
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

extension MembershipPlanAccountModel: CoreDataMappable, CoreDataIDMappable {
    func objectToMapTo(_ cdObject: CD_MembershipPlanAccount, in context: NSManagedObjectContext, delta: Bool, overrideID: String?) -> CD_MembershipPlanAccount {
        update(cdObject, \.id, with: id(orOverrideId: overrideID), delta: delta)
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

        cdObject.tiers.forEach {
            guard let tier = $0 as? CD_Tier else { return }
            context.delete(tier)
        }
        tiers?.forEach { tier in
            let overrideId = TierModel.overrideId(forParentId: id(orOverrideId: overrideID), withExtension: tier.id)
            let cdTier = tier.mapToCoreData(context, .update, overrideID: overrideId)
            update(cdTier, \.planAccount, with: cdObject, delta: delta)
            cdObject.addTiersObject(cdTier)
        }

        cdObject.planDocuments.forEach {
            guard let document = $0 as? CD_PlanDocument else { return }
            context.delete(document)
        }
        planDocuments?.forEach { document in
            let overrideId = PlanDocumentModel.overrideId(forParentId: id(orOverrideId: overrideID), withExtension: document.id)
            let cdPlanDocument = document.mapToCoreData(context, .update, overrideID: overrideId)
            update(cdPlanDocument, \.planAccount, with: cdObject, delta: delta)
            cdObject.addPlanDocumentsObject(cdPlanDocument)
        }

        cdObject.addFields.forEach {
            guard let field = $0 as? CD_AddField else { return }
            context.delete(field)
        }
        addFields?.forEach { field in
            let overrideId = AddFieldModel.overrideId(forParentId: id(orOverrideId: overrideID), withExtension: field.id)
            let cdAddField = field.mapToCoreData(context, .update, overrideID: overrideId)
            update(cdAddField, \.planAccount, with: cdObject, delta: delta)
            cdObject.addAddFieldsObject(cdAddField)
        }

        cdObject.authoriseFields.forEach {
            guard let field = $0 as? CD_AuthoriseField else { return }
            context.delete(field)
        }
        authoriseFields?.forEach { field in
            let overrideId = AuthoriseFieldModel.overrideId(forParentId: id(orOverrideId: overrideID), withExtension: field.id)
            let cdAuthField = field.mapToCoreData(context, .update, overrideID: overrideId)
            update(cdAuthField, \.planAccount, with: cdObject, delta: delta)
            cdObject.addAuthoriseFieldsObject(cdAuthField)
        }

        cdObject.registrationFields.forEach {
            guard let field = $0 as? CD_RegistrationField else { return }
            context.delete(field)
        }
        registrationFields?.forEach { field in
            let overrideId = RegistrationFieldModel.overrideId(forParentId: id(orOverrideId: overrideID), withExtension: field.id)
            let cdRegField = field.mapToCoreData(context, .update, overrideID: overrideId)
            update(cdRegField, \.planAccount, with: cdObject, delta: delta)
            cdObject.addRegistrationFieldsObject(cdRegField)
        }

        cdObject.enrolFields.forEach {
            guard let field = $0 as? CD_EnrolField else { return }
            context.delete(field)
        }
        enrolFields?.forEach { field in
            let overrideId = EnrolFieldModel.overrideId(forParentId: id(orOverrideId: overrideID), withExtension: field.id)
            let cdEnrolField = field.mapToCoreData(context, .update, overrideID: overrideId)
            update(cdEnrolField, \.planAccount, with: cdObject, delta: delta)
            cdObject.addEnrolFieldsObject(cdEnrolField)
        }

        return cdObject
    }
}
