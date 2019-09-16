//
//  ReasonCode.swift
//  binkapp
//
//  Created by Nick Farrant on 16/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

protocol ReasonCodeProtocol: Codable {
    var codeString: String { get }
    var description: String { get }
}

struct ReasonCodeRange: Codable {
    var rangeFrom: Int
    var rangeTo: Int
    var description: String

    var reasonCodes: [ReasonCode] {
        return ReasonCode.allCases.filter { rangeFrom...rangeTo ~= $0.rawValue }
    }
}

enum ReasonCode: Int, ReasonCodeProtocol, CaseIterable {
    static let generalStatusCodesRange = ReasonCodeRange(rangeFrom: 000, rangeTo: 099, description: "General Status Codes")
    static let addDataCodesCodesRange = ReasonCodeRange(rangeFrom: 100, rangeTo: 199, description: "Add Data Codes")
    static let enrolDataCodesRange = ReasonCodeRange(rangeFrom: 200, rangeTo: 299, description: "Enrol Data Codes")
    static let authDataCodesRange = ReasonCodeRange(rangeFrom: 300, rangeTo: 399, description: "Auth Data Codes")
    static let reservedCodesRange = ReasonCodeRange(rangeFrom: 400, rangeTo: 499, description: "Reserved for future use")

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
}
