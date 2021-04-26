//
//  PaymentCardScannerStrings.swift
//  binkapp
//
//  Created by Sean Williams on 03/11/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import CardScan

class PaymentCardScannerStrings: ScanStringsDataSource {
    func positionCard() -> String { return L10n.paymentScannerExplainerText }
    func widgetTitle() -> String { return L10n.paymentScannerWidgetTitle }
    func widgetExplainerText() -> String { return L10n.paymentScannerWidgetExplainerText }
    func scanCard() -> String { return "" }
    func backButton() -> String { return " " }
    func skipButton() -> String { return " " }
}
