//
//  PaymentCardModel.swift
//  binkapp
//
//  Created by Max Woodhams on 15/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

class PaymentCardCreateModel: Codable {
    var fullPan: String?
    var nameOnCard: String?
    var month: Int?
    var year: Int?
    var cardType: PaymentCardType?
    let uuid = UUID().uuidString
    
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
