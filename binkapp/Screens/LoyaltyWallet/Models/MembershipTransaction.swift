//
//  MembershipTransaction.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import CoreData

struct MembershipTransaction: Codable {
    let apiId: Int?
    let status: String?
    let timestamp: Double?
    let transactionDescription: String?
    let amounts: [MembershipCardAmount]?
}
extension MembershipTransaction: CoreDataMappable, CoreDataIDMappable {
    func objectToMapTo(_ cdObject: CD_MembershipTransaction, in context: NSManagedObjectContext, delta: Bool, overrideID: String?) -> CD_MembershipTransaction {
        update(cdObject, \.id, with: id, delta: delta)
        update(cdObject, \.status, with: status, delta: delta)
        update(cdObject, \.timestamp, with: NSNumber(value: timestamp ?? 0.0), delta: delta)

        cdObject.amounts.forEach {
            guard let amount = $0 as? CD_MembershipCardAmount else { return }
            context.delete(amount)
        }
        
        if let amounts = amounts {
            for (index, amount) in amounts.enumerated() {
                let indexID = MembershipCardModel.overrideId(forParentId: overrideID ?? id) + String(index)
                let cdAmount = amount.mapToCoreData(context, .update, overrideID: indexID)
                update(cdAmount, \.transaction, with: cdObject, delta: delta)
                cdObject.addAmountsObject(cdAmount)
            }
        }

        return cdObject
    }
}

