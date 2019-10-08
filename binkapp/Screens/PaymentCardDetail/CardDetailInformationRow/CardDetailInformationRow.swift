//
//  CardDetailInformationRow.swift
//  binkapp
//
//  Created by Nick Farrant on 08/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

struct CardDetailInformationRow {
    var type: RowType
    var action: () -> Void

    enum RowType {
        case securityAndPrivacy
        case deletePaymentCard

        var title: String {
            switch self {
            case .securityAndPrivacy:
                return "Security and privacy"
            case .deletePaymentCard:
                return "Delete this card"
            }
        }

        var subtitle: String {
            switch self {
            case .securityAndPrivacy:
                return "How we protect your data"
            case .deletePaymentCard:
                return "Remove this card from Bink"
            }
        }
    }
}

protocol CardDetailInformationRowFactory {
    static func makeInformationRows() -> [CardDetailInformationRow]
}

class PaymentCardDetailInformationRowFactory: CardDetailInformationRowFactory {
    static func makeInformationRows() -> [CardDetailInformationRow] {
        return [makeSecurityAndPrivacyRow(), makeDeletePaymentCardRow()]
    }

    private static func makeSecurityAndPrivacyRow() -> CardDetailInformationRow {
        return CardDetailInformationRow(type: .securityAndPrivacy) {
            print("security and privacy row")
        }
    }

    private static func makeDeletePaymentCardRow() -> CardDetailInformationRow {
        return CardDetailInformationRow(type: .deletePaymentCard) {
            print("delete this card row")
        }
    }
}
