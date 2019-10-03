//
//  PaymentCardModel.swift
//  binkapp
//
//  Created by Paul Tiriteu on 10/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import CoreData

struct PaymentCardModel: Codable {
    var apiId: Int?
    var membershipCards: [LinkedCardResponse]?
    var status: String?
    var card: PaymentCardCardResponse?
    var images: [MembershipCardImageModel]?
    var account: PaymentCardAccountResponse?

    enum CodingKeys: String, CodingKey {
        case apiId = "id"
        case membershipCards = "membership_cards"
        case status
        case card
        case images
        case account
    }
}

extension PaymentCardModel: CoreDataMappable, CoreDataIDMappable {
    func objectToMapTo(_ cdObject: CD_PaymentCard, in context: NSManagedObjectContext, delta: Bool, overrideID: String?) -> CD_PaymentCard {
        update(cdObject, \.id, with: overrideID ?? id, delta: delta)
        update(cdObject, \.status, with: status, delta: delta)

        if let card = card {
            let cdCard = card.mapToCoreData(context, .update, overrideID: PaymentCardCardResponse.overrideId(forParentId: id))
            update(cdCard, \.paymentCard, with: cdObject, delta: delta)
            update(cdObject, \.card, with: cdCard, delta: delta)
        } else {
            update(cdObject, \.card, with: nil, delta: false)
        }

        if let account = account {
            let cdAccount = account.mapToCoreData(context, .update, overrideID: PaymentCardAccountResponse.overrideId(forParentId: id))
            update(cdAccount, \.paymentCard, with: cdObject, delta: delta)
            update(cdObject, \.account, with: cdAccount, delta: delta)
        } else {
            update(cdObject, \.account, with: nil, delta: false)
        }


        cdObject.images.forEach {
            guard let image = $0 as? CD_MembershipPlanImage else { return }
            context.delete(image)
        }
        images?.forEach { image in
            let cdImage = image.mapToCoreData(context, .update, overrideID: nil)
            update(cdImage, \.paymentCard, with: cdObject, delta: delta)
            cdObject.addImagesObject(cdImage)
        }

        cdObject.linkedMembershipCards.forEach {
            guard let membershipCard = $0 as? CD_MembershipCard else { return }
            cdObject.removeLinkedMembershipCardsObject(membershipCard)
        }
        membershipCards?.filter({ $0.activeLink == true }).forEach { membershipCard in
            if let cdMembershipCard = context.fetchWithApiID(CD_MembershipCard.self, id: String(membershipCard.id ?? 0)) {
                cdObject.addLinkedMembershipCardsObject(cdMembershipCard)
                cdMembershipCard.addLinkedPaymentCardsObject(cdObject)
            }
        }

        return cdObject
    }
}
