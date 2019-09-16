//
//  ReasonCode.swift
//  binkapp
//
//  Created by Nick Farrant on 16/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import CoreData

protocol ReasonCodeProtocol: Codable {
    var codeString: String { get }
    var description: String { get }
}

struct ReasonCodeRange: Codable {
    var from: Int
    var to: Int
    var description: String

    var reasonCodes: [ReasonCode] {
        return ReasonCode.allCases.filter { from...to ~= $0.rawValue }
    }
}

enum ReasonCode: Int, ReasonCodeProtocol, CaseIterable {
    static let generalStatusCodesRange = ReasonCodeRange(from: 000, to: 099, description: "General Status Codes")
    static let addDataCodesCodesRange = ReasonCodeRange(from: 100, to: 199, description: "Add Data Codes")
    static let enrolDataCodesRange = ReasonCodeRange(from: 200, to: 299, description: "Enrol Data Codes")
    static let authDataCodesRange = ReasonCodeRange(from: 300, to: 399, description: "Auth Data Codes")
    static let reservedCodesRange = ReasonCodeRange(from: 400, to: 499, description: "Reserved for future use")

    case newDataSubmitted = 000
    case addFieldsBeingValidated = 100
    case accountDoesNotExist = 101
    case addDataRejectedByMerchant = 102
    case NoAuthorizationProvided = 103
    case accountNotRegistered = 105
    case enrolmentInProgress = 200
    case enrolmentDataRejectedByMerchant = 201
    case accountAlreadyExists = 202
    case enrolmentComplete = 203
    case authorizationCorrect = 300
    case authorizationInProgress = 301
    case noAuthorizationRequired = 302
    case authorizationDataRejectedByMerchant = 303
    case authorizationExpired = 304

    var codeString: String {
        return "X\(rawValue)"
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
        case .NoAuthorizationProvided:
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
        }
    }

    var apiId: Int? {
        return nil // This will force CoreDataIDMappable to kick in and give this object a computed id based on the parent object
    }
}

extension ReasonCode: CoreDataMappable, CoreDataIDMappable {
    func objectToMapTo(_ cdObject: CD_ReasonCode, in context: NSManagedObjectContext, delta: Bool, overrideID: String?) -> CD_ReasonCode {
        update(cdObject, \.id, with: id, delta: delta)
        update(cdObject, \.value, with: NSNumber(value: rawValue), delta: delta)
        update(cdObject, \.codeString, with: codeString, delta: delta)
        update(cdObject, \.codeDescription, with: description, delta: delta)

        return cdObject
    }
}
