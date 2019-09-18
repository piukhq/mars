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
    
    enum MembershipCardStatus: String {
        case authorised
        case unauthorised
        case pending
        case failed 
    }
    
    enum CodingKeys: String, CodingKey {
        case apiId = "id"
        case state
        case reasonCodes = "reason_codes"
    }
}

extension MembershipCardStatusModel: CoreDataMappable, CoreDataIDMappable {
    func objectToMapTo(_ cdObject: CD_MembershipCardStatus, in context: NSManagedObjectContext, delta: Bool, overrideID: String?) -> CD_MembershipCardStatus {
        update(cdObject, \.id, with: overrideID ?? id, delta: delta)
        update(cdObject, \.state, with: state, delta: delta)

        cdObject.reasonCodes.forEach {
            guard let reasonCode = $0 as? CD_ReasonCode else { return }
            context.delete(reasonCode)
        }
        reasonCodes?.forEach { reasonCode in
            let override = ReasonCode.overrideId(forParentId: overrideID ?? id)
            let cdReasonCode = reasonCode.mapToCoreData(context, .update, overrideID: "\(override)_\(reasonCode.rawValue)")
            update(cdReasonCode, \.status, with: cdObject, delta: delta)
            cdObject.addReasonCodesObject(cdReasonCode)
        }

        return cdObject
    }
}
