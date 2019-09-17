//
//  MembershipCardStatusModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import CoreData

struct MembershipCardStatusModel: Codable {
    let apiId: Int?
    let state: String?
    let reasonCodes: [ReasonCode]?
    
    enum CodingKeys: String, CodingKey {
        case apiId = "id"
        case state
        case reasonCodes = "reason_codes"
    }
}

extension MembershipCardStatusModel: CoreDataMappable, CoreDataIDMappable {
    func objectToMapTo(_ cdObject: CD_MembershipCardStatus, in context: NSManagedObjectContext, delta: Bool, overrideID: String?) -> CD_MembershipCardStatus {
        update(cdObject, \.id, with: id, delta: delta)
        update(cdObject, \.state, with: state, delta: delta)

        cdObject.reasonCodes.forEach {
            guard let reasonCode = $0 as? CD_ReasonCode else { return }
            context.delete(reasonCode)
        }
        reasonCodes?.forEach { reasonCode in
            let cdReasonCode = reasonCode.mapToCoreData(context, .update, overrideID: nil)
            update(cdReasonCode, \.status, with: cdObject, delta: delta)
            cdObject.addReasonCodesObject(cdReasonCode)
        }

        return cdObject
    }
}
