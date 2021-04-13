//
//  PaymentCardScannerStrings.swift
//  binkapp
//
//  Created by Sean Williams on 03/11/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import CardScan

class PaymentCardScannerStrings: ScanStringsDataSource {
    func positionCard() -> String { return "payment_scanner_explainer_text".localized }
    func widgetTitle() -> String { return "payment_scanner_widget_title".localized }
    func widgetExplainerText() -> String { return "payment_scanner_widget_explainer_text".localized }
    func scanCard() -> String { return "" }
    func backButton() -> String { return " " }
    func skipButton() -> String { return " " }
}
