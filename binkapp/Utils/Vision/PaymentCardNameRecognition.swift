//
//  PaymentCardNameRecognition.swift
//  binkapp
//
//  Created by Sean Williams on 24/05/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import Foundation

enum PaymentCardNameRecognition {
    static let ignoreList: Set = [
        "monzo", "customer", "debit", "visa", "mastercard", "navy", "american", "express", "thru", "good", "authorized", "signature", "wells", "navy", "credit", "federal", "union", "bank", "valid", "validfrom", "validthru", "llc", "business", "netspend", "goodthru", "chase", "fargo", "hsbc", "usaa", "chaseo", "commerce", "last", "of", "lastdayof", "check", "card", "inc", "first", "member", "since", "american", "express", "republic", "bmo", "capital", "one", "capitalone", "platinum", "expiry", "expires", "date", "expiration", "cash", "back", "td", "access", "international", "interac", "nterac", "entreprise", "business", "md", "enterprise", "fifth", "third", "fifththird", "world", "rewards", "citi", "member", "cardmember", "cardholder", "valued", "since", "membersince", "cardmembersince", "cardholdersince", "freedom", "quicksilver", "penfed", "use", "this", "card", "is", "subject", "to", "the", "inc", "not", "transferable", "gto", "mgy", "sign", "exp", "end", "from", "month", "year", "until", "from"
    ]
    
    static func nonNameWordMatch(_ text: String) -> Bool {
        let lowerCase = text.lowercased()
        return ignoreList.contains(lowerCase)
    }
    
    static func onlyLettersAndSpaces(_ text: String) -> Bool {
        let lettersAndSpace = text.reduce(true) { acc, value in
            let capitalLetter = value >= "A" && value <= "Z"
            // We're only going to accept upper case names
            // let lowerCaseLetter = value >= "a" && value <= "z"
            let space = value == " "
            return acc && (capitalLetter || space)
        }
        
        return lettersAndSpace
    }
}
