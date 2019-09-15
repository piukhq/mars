//
//  PaymentCardModel.swift
//  binkapp
//
//  Created by Max Woodhams on 15/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

class PaymentCardCreateModel {
    var fullPan: String?
    var nameOnCard: String?
    var month: String?
    var year: String?
    var cardType: PaymentCardType?
    
    init(fullPan: String?, nameOnCard: String?, month: String?, year: String?) {
        self.fullPan = fullPan
        self.nameOnCard = nameOnCard
        self.month = month
        self.year = year
        
        if let fullPan = fullPan { setType(with: fullPan) }
    }
    
    func setType(with pan: String) {
        self.cardType = PaymentCardType.type(from: pan)
    }
}
