//
//  AnalyticsEventTests.swift
//  binkappTests
//
//  Created by Ricardo Silva on 31/10/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import XCTest
@testable import binkapp

// swiftlint:disable all

final class AnalyticsEventTests: XCTestCase, CoreDataTestable {

    static var membershipCardPostModel: MembershipCardPostModel!
    static var membershipCardResponse: MembershipCardModel!
    static var membershipCardStatusModel: MembershipCardStatusModel!
    static var membershipCard: CD_MembershipCard!
    static var cardResponse: CardModel!
    
    static var membershipPlanAccountModel: MembershipPlanAccountModel!
    static var featureSetModel: FeatureSetModel!
    static var membershipPlanResponse: MembershipPlanModel!
    static var membershipPlan: CD_MembershipPlan!
    static var paymentCard: CD_PaymentCard!
    
    static var paymentCardCardResponse: PaymentCardCardResponse!
    static var basePaymentCardResponse: PaymentCardModel!
    static let linkedResponse = LinkedCardResponse(id: 500, activeLink: true)
    
    static let url = URL(string: "https://bink.com/privacy-policy/")
    
    static var paymentCardCreateModel = PaymentCardCreateModel(fullPan: "5454 5454 5454 5454", nameOnCard: "Rick Morty", month: 4, year: 2030)
    
    static let trackableCard = TrackableWalletCard(id: "500", loyaltyPlan: "500", paymentScheme: 1)
    
    override class func setUp() {
        featureSetModel = FeatureSetModel(apiId: 500, authorisationRequired: nil, transactionsAvailable: nil, digitalOnly: nil, hasPoints: true, cardType: .link, linkingSupport: [.add], hasVouchers: false)
        
        membershipPlanAccountModel = MembershipPlanAccountModel(apiId: 500, planName: "Test Plan", planNameCard: "Card Name", planURL: nil, companyName: "Tesco", category: nil, planSummary: nil, planDescription: nil, barcodeRedeemInstructions: nil, planRegisterInfo: nil, companyURL: nil, enrolIncentive: nil, forgottenPasswordUrl: nil, tiers: nil, planDocuments: nil, addFields: nil, authoriseFields: nil, registrationFields: nil, enrolFields: nil)
        
        membershipPlanResponse = MembershipPlanModel(apiId: 500, status: nil, featureSet: featureSetModel, images: nil, account: membershipPlanAccountModel, balances: nil, dynamicContent: nil, hasVouchers: true, card: cardResponse, goLive: "")
        
        mapResponseToManagedObject(membershipPlanResponse, managedObjectType: CD_MembershipPlan.self) { plan in
            self.membershipPlan = plan
        }
        
        membershipCardPostModel = MembershipCardPostModel(account: nil, membershipPlan: 500)
        
        cardResponse = CardModel(apiId: 500, barcode: "123456789", membershipId: "999 666", barcodeType: 0, colour: "#0000ff", secondaryColour: nil, merchantName: nil  )
        
        membershipCardStatusModel = MembershipCardStatusModel(apiId: 500, state: .authorised, reasonCodes: [.pointsScrapingLoginRequired])
        
        membershipCardResponse = MembershipCardModel(apiId: 500, membershipPlan: 500, membershipTransactions: nil, status: membershipCardStatusModel, card: cardResponse, images: nil, account: MembershipCardAccountModel(apiId: 500, tier: 1), paymentCards: nil, balances: nil, vouchers: nil, openedTime: nil)
        
        mapResponseToManagedObject(membershipCardResponse, managedObjectType: CD_MembershipCard.self) { membershipCard in
            self.membershipCard = membershipCard
        }
        
        paymentCardCardResponse = PaymentCardCardResponse(apiId: 500, firstSix: nil, lastFour: "1234", month: 30, year: 3000, country: nil, currencyCode: nil, nameOnCard: "Sean Williams", provider: .mastercard, type: nil)
                
        Self.basePaymentCardResponse = PaymentCardModel(apiId: 500, membershipCards: [Self.linkedResponse], status: "active", card: paymentCardCardResponse, account: PaymentCardAccountResponse(apiId: 0, verificationInProgress: nil, status: 0, consents: []))
        
        mapResponseToManagedObject(Self.basePaymentCardResponse, managedObjectType: CD_PaymentCard.self) { paymentCard in
            Self.paymentCard = paymentCard
        }
    }
    // MARK: - Generic events
    
    func test_genericEvents_correctStringAndDataFromEvent() throws {
        var event = GenericAnalyticsEvent.callToAction(identifier: "id")
        XCTAssertTrue(event.name == "call_to_action_pressed")
        XCTAssertTrue(event.data!["identifier"] as! String == "id")
        
        event = GenericAnalyticsEvent.paymentScan(success: true)
        XCTAssertTrue(event.name == "payment_scan")
        XCTAssertTrue(event.data!["success"] as! Int == 1)
    }
    
    // MARK: - Onboarding events
    
    func test_onboardingAnalytics_correctStringAndDataFromEvent() throws {
        var event = OnboardingAnalyticsEvent.start(journey: OnboardingAnalyticsEvent.Journey.login)
        XCTAssertTrue(event.name == "onboarding_start")
        XCTAssertNotNil(event.data!["onboarding_id"])
        XCTAssertTrue(event.data!["onboarding_journey"] as! String == "LOGIN")
        
        event = OnboardingAnalyticsEvent.userComplete
        XCTAssertTrue(event.name == "onboarding_user_complete")
        XCTAssertNotNil(event.data!["onboarding_id"])
        
        event = OnboardingAnalyticsEvent.serviceComplete
        XCTAssertTrue(event.name == "onboarding_service_complete")
        XCTAssertNotNil(event.data!["onboarding_id"])
        
        event = OnboardingAnalyticsEvent.end(didSucceed: true)
        XCTAssertTrue(event.name == "onboarding_end")
        XCTAssertNotNil(event.data!["onboarding_id"])
        XCTAssertTrue(event.data!["onboarding_success"] as! String == "true")
    }
    
    // MARK: - Card account events
    func test_cardAccountAnalytics_correctStringAndDataFromEvent() throws {
        var event = CardAccountAnalyticsEvent.addLoyaltyCardRequest(request: Self.membershipCardPostModel, formPurpose: .add)
        XCTAssertTrue(event.name == "add_loyalty_card_request")
        XCTAssertTrue(event.data!["loyalty_card_journey"] as! String == "ADD")
        XCTAssertTrue(event.data!["loyalty_plan"] as! Int == 500)
        XCTAssertTrue(event.data!["scanned_card"] as! String == "false")
        
        event = CardAccountAnalyticsEvent.addLoyaltyCardResponseSuccess(loyaltyCard: Self.membershipCard, formPurpose: .add, statusCode: 200)
        XCTAssertTrue(event.name == "add_loyalty_card_response_success")
        XCTAssertTrue(event.data!["loyalty_card_journey"] as! String == "ADD")
        XCTAssertTrue(event.data!["loyalty_reason_code"] as! String == "M103")
        XCTAssertTrue(event.data!["client_account_id"] as! String == "500")
        XCTAssertTrue(event.data!["account_is_new"] as! String == "false")
        XCTAssertTrue(event.data!["loyalty_plan"] as! Int == 500)
        XCTAssertTrue(event.data!["loyalty_status"] as! String == "authorised")
        
        event = CardAccountAnalyticsEvent.addLoyaltyCardResponseFail(request: Self.membershipCardPostModel, formPurpose: .add, responseData: NetworkResponseData(urlResponse: HTTPURLResponse(url: Self.url!, statusCode: 400, httpVersion: nil, headerFields: nil), errorMessage: "error"))
        XCTAssertTrue(event.name == "add_loyalty_card_response_fail")
        XCTAssertTrue(event.data!["error_code"] as! Int == 400)
        XCTAssertTrue(event.data!["loyalty_card_journey"] as! String == "ADD")
        XCTAssertTrue(event.data!["error_message"] as! String == "error")
        XCTAssertTrue(event.data!["loyalty_plan"] as! Int == 500)
        
        event = CardAccountAnalyticsEvent.addPaymentCardRequest(request: Self.paymentCardCreateModel)
        XCTAssertTrue(event.name == "add_payment_card_request")
        XCTAssertTrue(event.data!["payment_scheme"] as! Int == 1)
        
        event = CardAccountAnalyticsEvent.addPaymentCardResponseSuccess(request: Self.paymentCardCreateModel, paymentCard: Self.paymentCard, statusCode: 200)
        XCTAssertTrue(event.name == "add_payment_card_response_success")
        XCTAssertTrue(event.data!["payment_status"] as! String == "active")
        XCTAssertTrue(event.data!["account_is_new"] as! String == "false")
        XCTAssertTrue(event.data!["client_account_id"] as! String == "500")
        XCTAssertTrue(event.data!["payment_scheme"] as! Int == 1)
        
        event = CardAccountAnalyticsEvent.addPaymentCardResponseFail(request: Self.paymentCardCreateModel, responseData: NetworkResponseData(urlResponse: HTTPURLResponse(url: Self.url!, statusCode: 400, httpVersion: nil, headerFields: nil), errorMessage: "error"))
        XCTAssertTrue(event.name == "add_payment_card_response_fail")
        XCTAssertTrue(event.data!["error_code"] as! Int == 400)
        XCTAssertTrue(event.data!["error_message"] as! String == "error")
        XCTAssertTrue(event.data!["payment_scheme"] as! Int == 1)
        
        event = CardAccountAnalyticsEvent.deleteLoyaltyCard(card: Self.membershipCard)
        XCTAssertTrue(event.name == "delete_loyalty_card_request")
        XCTAssertTrue(event.data!["loyalty_plan"] as! Int == 500)
        XCTAssertTrue(event.data!["client_account_id"] as! String == "500")
        
        event = CardAccountAnalyticsEvent.deleteLoyaltyCardResponseSuccess(card: Self.trackableCard)
        XCTAssertTrue(event.name == "delete_loyalty_card_response_success")
        XCTAssertTrue(event.data!["loyalty_plan"] as! Int == 500)
        XCTAssertTrue(event.data!["client_account_id"] as! String == "500")
        
        event = CardAccountAnalyticsEvent.deleteLoyaltyCardResponseFail(card: Self.trackableCard, responseData: NetworkResponseData(urlResponse: HTTPURLResponse(url: Self.url!, statusCode: 400, httpVersion: nil, headerFields: nil), errorMessage: "error"))
        XCTAssertTrue(event.name == "delete_loyalty_card_response_fail")
        XCTAssertTrue(event.data!["loyalty_plan"] as! Int == 500)
        XCTAssertTrue(event.data!["client_account_id"] as! String == "500")
        XCTAssertTrue(event.data!["error_code"] as! Int == 400)
        XCTAssertTrue(event.data!["error_message"] as! String == "error")
        
        event = CardAccountAnalyticsEvent.deletePaymentCard(card: Self.paymentCard)
        XCTAssertTrue(event.name == "delete_payment_card_request")
        XCTAssertTrue(event.data!["payment_scheme"] as! Int == 1)
        XCTAssertTrue(event.data!["client_account_id"] as! String == "500")
        
        event = CardAccountAnalyticsEvent.deletePaymentCardResponseSuccess(card: Self.trackableCard)
        XCTAssertTrue(event.name == "delete_payment_card_response_success")
        XCTAssertTrue(event.data!["payment_scheme"] as! Int == 1)
        XCTAssertTrue(event.data!["client_account_id"] as! String == "500")
        
        event = CardAccountAnalyticsEvent.deletePaymentCardResponseFail(card: Self.trackableCard, responseData: NetworkResponseData(urlResponse: HTTPURLResponse(url: Self.url!, statusCode: 400, httpVersion: nil, headerFields: nil), errorMessage: "error"))
        XCTAssertTrue(event.name == "delete_payment_card_response_fail")
        XCTAssertTrue(event.data!["payment_scheme"] as! Int == 1)
        XCTAssertTrue(event.data!["client_account_id"] as! String == "500")
        XCTAssertTrue(event.data!["error_code"] as! Int == 400)
        XCTAssertTrue(event.data!["error_message"] as! String == "error")
        
        event = CardAccountAnalyticsEvent.loyaltyCardStatus(loyaltyCard: Self.membershipCard, newStatus: .authorised)
        XCTAssertTrue(event.name == "loyalty_card_status")
        XCTAssertTrue(event.data!["client_account_id"] as! String == "500")
        XCTAssertTrue(event.data!["status"] as! String == "authorised")
        XCTAssertTrue(event.data!["loyalty_card_plan"] as! Int == 500)
        
        event = CardAccountAnalyticsEvent.paymentCardStatus(paymentCard: Self.paymentCard, newStatus: "authorised")
        XCTAssertTrue(event.name == "payment_card_status")
        XCTAssertTrue(event.data!["client_account_id"] as! String == "500")
        XCTAssertTrue(event.data!["status"] as! String == "authorised")
        XCTAssertTrue(event.data!["payment_scheme"] as! Int == 1)
    }
    
    // MARK: - PLLAnalytics events
    func test_pLLAnalyticsEvent_correctStringAndDataFromEvent() throws {
        var event = PLLAnalyticsEvent.pllActive(loyaltyCard: Self.membershipCard, paymentCard: Self.paymentCard)
        XCTAssertTrue(event.name == "pll_active")
        XCTAssertTrue(event.data!["payment_id"] as! String == "500")
        XCTAssertTrue(event.data!["loyalty_id"] as! String == "500")
        XCTAssertTrue(event.data!["loyalty_plan"] as! Int == 500)
        XCTAssertTrue(event.data!["link_id"] as! String == "500/500")
        
        event = PLLAnalyticsEvent.pllDelete(loyaltyCard: Self.membershipCard, paymentCard: Self.paymentCard)
        XCTAssertTrue(event.name == "pll_delete")
        XCTAssertTrue(event.data!["payment_id"] as! String == "500")
        XCTAssertTrue(event.data!["loyalty_id"] as! String == "500")
        XCTAssertTrue(event.data!["link_id"] as! String == "500/500")
        XCTAssertTrue(event.data!["loyalty_plan"] as! Int == 500)
        
        event = PLLAnalyticsEvent.pllPatch(loyaltyCard: Self.membershipCard, paymentCard: Self.paymentCard, response: Self.basePaymentCardResponse)
        XCTAssertTrue(event.name == "pll_patch")
        XCTAssertTrue(event.data!["payment_id"] as! String == "500")
        XCTAssertTrue(event.data!["loyalty_id"] as! String == "500")
        XCTAssertTrue(event.data!["link_id"] as! String == "500/500")
        XCTAssertTrue(event.data!["loyalty_plan"] as! Int == 500)
    }
    
    // MARK: - InAppReviewAnalytics events
    func test_inAppReviewAnalyticsEvent_correctStringAndDataFromEvent() throws {
        Current.inAppReviewableJourney = PllLoyaltyInAppReviewableJourney()
        var event = InAppReviewAnalyticsEvent.add
        XCTAssertTrue(event.name == "in_app_review_request")
        XCTAssertTrue(event.data!["review_trigger"] as! String == "ADD")
        XCTAssertTrue(InAppReviewAnalyticsEvent.eventForInProgressJourney == InAppReviewAnalyticsEvent.add)
        
        Current.inAppReviewableJourney = TransactionsHistoryInAppReviewableJourney()
        event = InAppReviewAnalyticsEvent.transactions
        event = InAppReviewAnalyticsEvent.transactions
        XCTAssertTrue(event.name == "in_app_review_request")
        XCTAssertTrue(event.data!["review_trigger"] as! String == "TRANSACTIONS")
        XCTAssertTrue(InAppReviewAnalyticsEvent.eventForInProgressJourney == InAppReviewAnalyticsEvent.transactions)
        
        Current.inAppReviewableJourney = TimeAndUsageBasedInAppReviewableJourney()
        event = InAppReviewAnalyticsEvent.time
        event = InAppReviewAnalyticsEvent.time
        XCTAssertTrue(event.name == "in_app_review_request")
        XCTAssertTrue(event.data!["review_trigger"] as! String == "TIME")
        XCTAssertTrue(InAppReviewAnalyticsEvent.eventForInProgressJourney == InAppReviewAnalyticsEvent.time)
    }
    
    // MARK: - DynamicActionsAnalytics events
    func test_dynamicActionsAnalyticsEvent_correctStringAndDataFromEvent() throws {
        let action = DynamicAction(name: "action", type: nil, startDate: nil, endDate: nil, locations: nil, event: nil, enabledLive: false, forceDebug: false)
        var event = DynamicActionsAnalyticsEvent.triggered(action)
        XCTAssertTrue(event.name == "dynamic_action_triggered")
        XCTAssertTrue(event.data!["dynamic_action_name"] as! String == "action")
    }
    
    // MARK: - Recommended App Update
    func test_recommendedAppUpdateAnalyticsEvent_correctStringAndDataFromEvent() throws {
        var event = RecommendedAppUpdateAnalyticsEvent.openAppStore
        XCTAssertTrue(event.name == "recommended_app_update_action")
        XCTAssertTrue(event.data!["user_action"] as! String == "open_app_store")
        
        event = RecommendedAppUpdateAnalyticsEvent.maybeLater
        XCTAssertTrue(event.name == "recommended_app_update_action")
        XCTAssertTrue(event.data!["user_action"] as! String == "maybe_later")
        
        event = RecommendedAppUpdateAnalyticsEvent.skipThisVersion
        XCTAssertTrue(event.name == "recommended_app_update_action")
        XCTAssertTrue(event.data!["user_action"] as! String == "skip_this_version")
    }
    
    // MARK: - Widgets
    func test_widgetAnalyticsEvent_correctStringAndDataFromEvent() throws {
        var event = WidgetAnalyticsEvent.widgetLaunch(urlPath: "path", widgetType: .quickLaunch)
        XCTAssertTrue(event.name == "widget_launch")
        XCTAssertTrue(event.data!["launch_reason"] as! String == "path")
        XCTAssertTrue(event.data!["widget_slug"] as! String == "ql")
    }
}
