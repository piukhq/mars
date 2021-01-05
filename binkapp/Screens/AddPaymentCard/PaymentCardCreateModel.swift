//
//  PaymentCardModel.swift
//  binkapp
//
//  Created by Max Woodhams on 15/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import CardScan

class PaymentCardCreateModel: Codable {
    var fullPan: String?
    var nameOnCard: String?
    var month: Int?
    var year: Int?
    var cardType: PaymentCardType?
    var uuid = UUID().uuidString
    
    init(fullPan: String?, nameOnCard: String?, month: Int?, year: Int?) {
        self.fullPan = fullPan
        self.nameOnCard = nameOnCard
        self.month = month
        self.year = year
        
        if let fullPan = fullPan {
            setType(with: fullPan)
            formattFullPanIfNecessary()
        }
    }
    
    func setType(with pan: String) {
        self.cardType = PaymentCardType.type(from: pan)
    }
    
    private func formattFullPanIfNecessary() {
        /// If we have scanned a card, we will have a fullPan available
        /// This pan should not contain any spaces, but guard against it anyway
        if fullPan?.contains(" ") == false {
            /// Using the indexes given a card type, insert a whitespace character at each index in the array
            if var formattedFullPan = fullPan, let whitespaceIndexes = cardType?.lengthRange().whitespaceIndexes {
                whitespaceIndexes.forEach { index in
                    formattedFullPan.insert(" ", at: formattedFullPan.index(formattedFullPan.startIndex, offsetBy: index))
                }
                
                /// Set the full pan to our newly formatted pan which includes whitespace
                fullPan = formattedFullPan
            }
        }
    }
}

extension CreditCard {
    func expiryMonthInteger() -> Int? {
        guard let expiryMonth = expiryMonth, let expiryMonthInt = Int(expiryMonth)  else {
            return nil
        }
        
        return expiryMonthInt
    }
    
    func expiryYearInteger() -> Int? {
        var year = expiryYear
        
        // Is the digit exactly two? We need to prepend 20 if so
        if let safeYear = year, safeYear.count == 2 {
            year = "20" + safeYear
        }
        
        guard let expiryYear = year, let expiryYearInt = Int(expiryYear)  else {
            return nil
        }
        
        return expiryYearInt
    }
}
