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
    func makeInformationRows() -> [CardDetailInformationRow]
}

protocol CardDetailInformationRowFactoryDelegate: AnyObject {
    func cardDetailInformationRowFactory(_ factory: PaymentCardDetailInformationRowFactory, shouldPerformActionForRowType informationRowType: CardDetailInformationRow.RowType)
}

class PaymentCardDetailInformationRowFactory: CardDetailInformationRowFactory {
    weak var delegate: CardDetailInformationRowFactoryDelegate?

    func makeInformationRows() -> [CardDetailInformationRow] {
        return [makeSecurityAndPrivacyRow(), makeDeletePaymentCardRow()]
    }

    private func makeSecurityAndPrivacyRow() -> CardDetailInformationRow {
        return CardDetailInformationRow(type: .securityAndPrivacy) { [weak self] in
            guard let self = self else { return }
            self.delegate?.cardDetailInformationRowFactory(self, shouldPerformActionForRowType: .securityAndPrivacy)
        }
    }

    private func makeDeletePaymentCardRow() -> CardDetailInformationRow {
        return CardDetailInformationRow(type: .deletePaymentCard) { [weak self] in
            guard let self = self else { return }
            self.delegate?.cardDetailInformationRowFactory(self, shouldPerformActionForRowType: .deletePaymentCard)
        }
    }
}
