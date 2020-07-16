//
//  ReasonCode.swift
//  binkapp
//
//  Created by Nick Farrant on 16/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import CoreData

struct ReasonCodeRange: Codable {
    var from: Int
    var to: Int
    var description: String

    var reasonCodes: [ReasonCode] {
        return ReasonCode.allCases.filter { from...to ~= $0.code }
    }
}

enum ReasonCode: String, Codable, CaseIterable {
    static let generalStatusCodesRange = ReasonCodeRange(from: 000, to: 099, description: "General Status Codes")
    static let addDataCodesCodesRange = ReasonCodeRange(from: 100, to: 199, description: "Add Data Codes")
    static let enrolDataCodesRange = ReasonCodeRange(from: 200, to: 299, description: "Enrol Data Codes")
    static let authDataCodesRange = ReasonCodeRange(from: 300, to: 399, description: "Auth Data Codes")
    static let reservedCodesRange = ReasonCodeRange(from: 400, to: 499, description: "Reserved for future use")

    case newDataSubmitted = "X000"
    case addFieldsBeingValidated = "X100"
    case accountDoesNotExist = "X101"
    case addDataRejectedByMerchant = "X102"
    case noAuthorizationProvided = "X103"
    case accountNotRegistered = "X105"
    case enrolmentInProgress = "X200"
    case enrolmentDataRejectedByMerchant = "X201"
    case accountAlreadyExists = "X202"
    case enrolmentComplete = "X203"
    case authorizationCorrect = "X300"
    case authorizationInProgress = "X301"
    case noAuthorizationRequired = "X302"
    case authorizationDataRejectedByMerchant = "X303"
    case authorizationExpired = "X304"
    
    // Local points scraping
    case attemptingToScrapePointsValue = "M100"
    case pointsScrapingSuccessful = "M300"
    case pointsScrapingLoginFailed = "M102"

    var code: Int {
        let codeString = String(rawValue.suffix(3))
        return Int(codeString)! // Tech debt
    }

    var description: String {
        switch self {
        case .newDataSubmitted:
            return "New data submitted/modified"
        case .addFieldsBeingValidated:
            return "Add field being validated"
        case .accountDoesNotExist:
            return "Account does not exist"
        case .addDataRejectedByMerchant:
            return "Add data rejected by merchant"
        case .noAuthorizationProvided:
            return "No authorization provided"
        case .accountNotRegistered:
            return "Account not registered"
        case .enrolmentInProgress:
            return "Enrolment in progress"
        case .enrolmentDataRejectedByMerchant:
            return "Enrolment data rejected by merchant"
        case .accountAlreadyExists:
            return "Account already exists"
        case .enrolmentComplete:
            return "Enrolment complete"
        case .authorizationCorrect:
            return "Authorization correct"
        case .authorizationInProgress:
            return "Authorization in progress"
        case .noAuthorizationRequired:
            return "No authorization required"
        case .authorizationDataRejectedByMerchant:
            return "Authorization data rejected merchant"
        case .authorizationExpired:
            return "Authorization expired"
        case .attemptingToScrapePointsValue:
            return "Attemping to scrape points value"
        case .pointsScrapingSuccessful:
            return "Points scraping successful"
        case .pointsScrapingLoginFailed:
            return "Points scraping login failed"
        }
    }

    var apiId: Int? {
        return nil // This will force CoreDataIDMappable to kick in and give this object a computed id based on the parent object
    }
}

extension ReasonCode: CoreDataMappable, CoreDataIDMappable {
    func objectToMapTo(_ cdObject: CD_ReasonCode, in context: NSManagedObjectContext, delta: Bool, overrideID: String?) -> CD_ReasonCode {
        update(cdObject, \.id, with: overrideID ?? id, delta: delta)
        update(cdObject, \.value, with: rawValue, delta: delta)

        return cdObject
    }
}
