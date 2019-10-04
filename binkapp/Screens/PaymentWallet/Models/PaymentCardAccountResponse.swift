//
//  PaymentCardAccountResponse.swift
//  binkapp
//
//  Created by Nick Farrant on 29/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import CoreData

struct PaymentCardAccountResponse: Codable {
    var apiId: Int?
    var verificationInProgress: Bool?
    var status: Int?
    var consents: [PaymentCardAccountConsentsResponse]?

    enum CodingKeys: String, CodingKey {
        case apiId = "id"
        case verificationInProgress = "verification_in_progress"
        case status
        case consents
    }
}

extension PaymentCardAccountResponse: CoreDataMappable, CoreDataIDMappable {
    func objectToMapTo(_ cdObject: CD_PaymentCardAccount, in context: NSManagedObjectContext, delta: Bool, overrideID: String?) -> CD_PaymentCardAccount {
        update(cdObject, \.id, with: overrideID ?? id, delta: delta)
        update(cdObject, \.status, with: NSNumber(value: status ?? 0), delta: delta)

        cdObject.consents.forEach {
            guard let consent = $0 as? CD_PaymentCardAccountConsents else { return }
            context.delete(consent)
        }
        consents?.forEach { consent in
            let cdConsent = consent.mapToCoreData(context, .update, overrideID: nil)
            update(cdConsent, \.account, with: cdObject, delta: delta)
            cdObject.addConsentsObject(cdConsent)
        }

        return cdObject
    }
}
