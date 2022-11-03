//
//  PointsScrapingManagerTests.swift
//  binkappTests
//
//  Created by Ricardo Silva on 27/10/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import XCTest
@testable import binkapp
import KeychainAccess

// swiftlint:disable all

final class PointsScrapingManagerTests: XCTestCase, CoreDataTestable {
    static var membershipPlan: CD_MembershipPlan!
    static var membershipPlanResponse: MembershipPlanModel!
    static var membershipPlanAccountModel: MembershipPlanAccountModel!
    
    static var membershipCardResponse: MembershipCardModel!
    
    static var membershipCardBalanceModel: MembershipCardBalanceModel!
    
    static var membershipCardStatusModel: MembershipCardStatusModel!
    
    static var featureSetModel: FeatureSetModel!
    
    static var cardResponse: CardModel!
    
    static var membershipCard: CD_MembershipCard!
    
    static var voucherResponse: VoucherModel!
    static var voucher: CD_Voucher!
    
    //static var sut: PointsScrapingManager!
    
    let keychain = Keychain(service: APIConstants.bundleID)
    
//    override func setUpWithError() throws {
//        Current.pointsScrapingManager.start()
//    }
//
//    override func tearDownWithError() throws {
//        Current.pointsScrapingManager.handleLogout()
//        Current.pointsScrapingManager.handleDelete(for: Self.membershipCard)
//    }
    
    override class func setUp() {
        super.setUp()
        
        let burnModel = VoucherBurnModel(apiId: 500, currency: nil, prefix: "£", suffix: "gift", value: 500, type: "voucher")
        let stampsVoucherEarnModel = VoucherEarnModel(apiId: 500, currency: nil, prefix: "£", suffix: "gift", type: .accumulator, targetValue: 600, value: 500)
        voucherResponse = VoucherModel(apiId: 500, state: .inProgress, code: "123456", barcode: nil, barcodeType: nil, headline: nil, subtext: nil, dateRedeemed: 1536080100, dateIssued: 3332020, expiryDate: 1535080100, earn: stampsVoucherEarnModel, burn: burnModel)
        
        cardResponse = CardModel(apiId: 500, barcode: "123456789", membershipId: "999 666", barcodeType: 0, colour: "#0000ff", secondaryColour: nil)
        
        featureSetModel = FeatureSetModel(apiId: 500, authorisationRequired: nil, transactionsAvailable: nil, digitalOnly: nil, hasPoints: true, cardType: .link, linkingSupport: [.add], hasVouchers: false)
        
        membershipPlanAccountModel = MembershipPlanAccountModel(apiId: 64, planName: "Test Plan", planNameCard: "Card Name", planURL: nil, companyName: "Tesco", category: nil, planSummary: nil, planDescription: nil, barcodeRedeemInstructions: nil, planRegisterInfo: nil, companyURL: nil, enrolIncentive: nil, forgottenPasswordUrl: nil, tiers: nil, planDocuments: nil, addFields: nil, authoriseFields: nil, registrationFields: nil, enrolFields: nil)
        
        membershipPlanResponse = MembershipPlanModel(apiId: 64, status: nil, featureSet: featureSetModel, images: nil, account: membershipPlanAccountModel, balances: nil, dynamicContent: nil, hasVouchers: true, card: cardResponse)
        
        mapResponseToManagedObject(membershipPlanResponse, managedObjectType: CD_MembershipPlan.self) { plan in
            self.membershipPlan = plan
        }
        
        membershipCardBalanceModel = MembershipCardBalanceModel(apiId: 500, value: 500, currency: nil, prefix: "£", suffix: nil, updatedAt: nil)
        
        membershipCardStatusModel = MembershipCardStatusModel(apiId: 500, state: .authorised, reasonCodes: [.pointsScrapingLoginRequired])
        
        membershipCardResponse = MembershipCardModel(apiId: 500, membershipPlan: 64, membershipTransactions: nil, status: membershipCardStatusModel, card: cardResponse, images: nil, account: MembershipCardAccountModel(apiId: 500, tier: 1), paymentCards: nil, balances: [membershipCardBalanceModel], vouchers: [voucherResponse])
        
        mapResponseToManagedObject(membershipCardResponse, managedObjectType: CD_MembershipCard.self) { membershipCard in
            self.membershipCard = membershipCard
            self.membershipCard.membershipPlan = self.membershipPlan
        }
        
        //sut = PointsScrapingManager()
        //sut.start()
    }
    
    func test_PointsScrapingManagerError_Erros() throws {
        var e = PointsScrapingManager.PointsScrapingManagerError.failedToStoreCredentials
        XCTAssertTrue(e.message == "Failed to store credentials")
        
        e = PointsScrapingManager.PointsScrapingManagerError.failedToRetrieveCredentials
        XCTAssertTrue(e.message == "Failed to retrieve credentials")
        
        e = PointsScrapingManager.PointsScrapingManagerError.failedToEnableMembershipCardForPointsScraping
        XCTAssertTrue(e.message == "Failed to enable membership card for points scraping")
        
        e = PointsScrapingManager.PointsScrapingManagerError.failedToGetMembershipPlanFromRequest
        XCTAssertTrue(e.message == "Failed to get membership plan from request")
        
        e = PointsScrapingManager.PointsScrapingManagerError.failedToGetAgentForMembershipPlan
        XCTAssertTrue(e.message == "Failed to get agent for membership plan")
    }
    
    // MARK: Scraping utility errors
    
    func test_scrapingUtilityErrors_correctMessage() {
        var error = WebScrapingUtilityError.agentProvidedInvalidUrl
        XCTAssertTrue(error.domain == .webScrapingUtility)
        XCTAssertTrue(error.message == "Agent provided invalid URL")
        XCTAssertTrue(error.level == .client)
        XCTAssertNil(error.underlyingError)
        
        error = WebScrapingUtilityError.scriptFileNotFound
        XCTAssertTrue(error.message == "Script file not found")
        XCTAssertTrue(error.level == .client)
        
        error = WebScrapingUtilityError.failedToExecuteScript
        XCTAssertTrue(error.message == "Failed to execute script")
        XCTAssertTrue(error.level == .client)
        
        error = WebScrapingUtilityError.failedToCastReturnValue
        XCTAssertTrue(error.message == "Failed to cast return value")
        XCTAssertTrue(error.level == .site)
        
        error = WebScrapingUtilityError.failedToAssignWebView
        XCTAssertTrue(error.message == "Failed to assign web view")
        XCTAssertTrue(error.level == .client)
        
        error = WebScrapingUtilityError.userDismissedWebView
        XCTAssertTrue(error.message == "User dismissed web view for user action")
        XCTAssertTrue(error.level == .user)
        
        error = WebScrapingUtilityError.unhandledIdling
        XCTAssertTrue(error.message == "Unhandled idling")
        XCTAssertTrue(error.level == .site)
        
        error = WebScrapingUtilityError.javascriptError
        XCTAssertTrue(error.message == "Javascript error")
        XCTAssertTrue(error.level == .client)
        
        error = WebScrapingUtilityError.noJavascriptResponse
        XCTAssertTrue(error.message == "No javascript response")
        XCTAssertTrue(error.level == .site)
        
        error = WebScrapingUtilityError.failedToDecodeJavascripResponse
        XCTAssertTrue(error.message == "Failed to decode javascript response")
        XCTAssertTrue(error.level == .client)
        
        error = WebScrapingUtilityError.incorrectCredentials(errorMessage: "error")
        XCTAssertTrue(error.message == "Login failed - incorrect credentials")
        XCTAssertTrue(error.underlyingError == "error")
        XCTAssertTrue(error.level == .user)
        
        error = WebScrapingUtilityError.genericFailure(errorMessage: "error")
        XCTAssertTrue(error.message == "Local points collection uncategorized failure")
        XCTAssertTrue(error.underlyingError == "error")
        XCTAssertTrue(error.level == .site)
    }
    
//    func test_canMakeCredentials() throws {
//        let field = FormField(
//            title: "Name on card",
//            placeholder: "J Appleseed",
//            validation: "^(((?=.{1,}$)[A-Za-z\\-\\u00C0-\\u00FF' ])+\\s*)$",
//            fieldType: .email,
//            value: "email@email.com",
//            updated: { field, newValue in
//
//            },
//            shouldChange: { (field, textField, range, newValue) in return false},
//            fieldExited: { field in },
//            columnKind: .lpcAuth,
//            forcedValue: "email@email.com",
//            fieldCommonName: .email
//        )
//
//        let passField = FormField(
//            title: "Name on card",
//            placeholder: "J Appleseed",
//            validation: "^(((?=.{1,}$)[A-Za-z\\-\\u00C0-\\u00FF' ])+\\s*)$",
//            fieldType: .text,
//            value: "pass",
//            updated: { field, newValue in },
//            shouldChange: { (field, textField, range, newValue) in return false},
//            fieldExited: { field in },
//            columnKind: .lpcAuth,
//            forcedValue: "pass",
//            fieldCommonName: .password
//        )
//        let credentials = Current.pointsScrapingManager.makeCredentials(fromFormFields: [field, passField], membershipPlanId: "64")
//        XCTAssertNotNil(credentials)
//    }
    
//    func test_enableLocalScrapPoints_storesValuesinKeychain() throws {
//        let model = MembershipCardPostModel(account: nil, membershipPlan: 64)
//        let credentials = WebScrapingCredentials(username: "email@email.com", password: "pass", cardNumber: "5454")
//        try Current.pointsScrapingManager.enableLocalPointsScrapingForCardIfPossible(withRequest: model, credentials: credentials, membershipCard: Self.membershipCard)
//
//        let key = String(format: "com.bink.wallet.pointsScraping.credentials.cardId_%@.%@", "500", PointsScrapingManager.CredentialStoreType.username.rawValue)
//        let value = try keychain.get(key)
//
//        _ = XCTWaiter.wait(for: [self.expectation(description: "Wait for network call closure to complete")], timeout: 10.0)
//
//        XCTAssertTrue(value! == "email@email.com")
//
//        let v = Current.pointsScrapingManager.canAttemptRetry(for: Self.membershipCard)
//        print(v)
//    }
    
//    func test_retrieveCredentials() throws {
//        let model = MembershipCardPostModel(account: nil, membershipPlan: 64)
//        let credentials = WebScrapingCredentials(username: "email@email.com", password: "pass", cardNumber: "5454")
//        try Current.pointsScrapingManager.enableLocalPointsScrapingForCardIfPossible(withRequest: model, credentials: credentials, membershipCard: Self.membershipCard)
//        
//        let retrivedCredentials = try Current.pointsScrapingManager.retrieveCredentials(forMembershipCardId: "500")
//        
//        XCTAssertNotNil(retrivedCredentials)
//        XCTAssertTrue(retrivedCredentials.username == "email@email.com")
//    }
    
    func test_precessingQueue_shouldNotbeEmpty() throws {
        Current.pointsScrapingManager.performBalanceRefresh(for: Self.membershipCard)
        XCTAssertTrue(!Current.pointsScrapingManager.processingQueue.isEmpty)
    }
    
    func test_handleLogout() throws {
        let model = MembershipCardPostModel(account: nil, membershipPlan: 64)
        let credentials = WebScrapingCredentials(username: "email@email.com", password: "pass", cardNumber: "5454")
        try Current.pointsScrapingManager.enableLocalPointsScrapingForCardIfPossible(withRequest: model, credentials: credentials, membershipCard: Self.membershipCard)

        Current.pointsScrapingManager.handleLogout()

        XCTAssertTrue(Current.pointsScrapingManager.processingQueue.isEmpty)
    }

    func test_handledelete() throws {
        let model = MembershipCardPostModel(account: nil, membershipPlan: 64)
        let credentials = WebScrapingCredentials(username: "email@email.com", password: "pass", cardNumber: "5454")
        try Current.pointsScrapingManager.enableLocalPointsScrapingForCardIfPossible(withRequest: model, credentials: credentials, membershipCard: Self.membershipCard)

        Current.pointsScrapingManager.handleDelete(for: Self.membershipCard)

        XCTAssertTrue(Current.pointsScrapingManager.processingQueue.isEmpty)

        let key = String(format: "com.bink.wallet.pointsScraping.credentials.cardId_%@.%@", "500", PointsScrapingManager.CredentialStoreType.username.rawValue)
        let value = try keychain.get(key)

        XCTAssertNil(value)
    }
    
}
