//
//  AuthAndAddViewModelTests.swift
//  binkappTests
//
//  Created by Ricardo Silva on 27/10/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import XCTest
import Mocker
@testable import binkapp

// swiftlint:disable all

final class AuthAndAddViewModelTests: XCTestCase, CoreDataTestable {
    
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
    
    static var sut: AuthAndAddViewModel!
    
    override class func setUp() {
        super.setUp()
        
        let burnModel = VoucherBurnModel(apiId: 500, currency: nil, prefix: "£", suffix: "gift", value: 500, type: "voucher")
        let stampsVoucherEarnModel = VoucherEarnModel(apiId: 500, currency: nil, prefix: "£", suffix: "gift", type: .accumulator, targetValue: 600, value: 500)
        voucherResponse = VoucherModel(apiId: 500, state: .inProgress, code: "123456", barcode: nil, barcodeType: nil, headline: nil, subtext: nil, dateRedeemed: 1536080100, dateIssued: 3332020, expiryDate: 1535080100, earn: stampsVoucherEarnModel, burn: burnModel)
        
        cardResponse = CardModel(apiId: 500, barcode: "123456789", membershipId: "999 666", barcodeType: 0, colour: "#0000ff", secondaryColour: nil)
        
        featureSetModel = FeatureSetModel(apiId: 500, authorisationRequired: nil, transactionsAvailable: nil, digitalOnly: nil, hasPoints: true, cardType: .link, linkingSupport: [.add], hasVouchers: false)
        
        membershipPlanAccountModel = MembershipPlanAccountModel(apiId: 500, planName: "Test Plan", planNameCard: "Card Name", planURL: nil, companyName: "Tesco", category: nil, planSummary: nil, planDescription: nil, barcodeRedeemInstructions: nil, planRegisterInfo: nil, companyURL: nil, enrolIncentive: nil, forgottenPasswordUrl: nil, tiers: nil, planDocuments: nil, addFields: nil, authoriseFields: nil, registrationFields: nil, enrolFields: nil)
        
        membershipPlanResponse = MembershipPlanModel(apiId: 500, status: nil, featureSet: featureSetModel, images: nil, account: membershipPlanAccountModel, balances: nil, dynamicContent: nil, hasVouchers: true, card: cardResponse)
        
        mapResponseToManagedObject(membershipPlanResponse, managedObjectType: CD_MembershipPlan.self) { plan in
            self.membershipPlan = plan
        }
        
        membershipCardBalanceModel = MembershipCardBalanceModel(apiId: 500, value: 500, currency: nil, prefix: "£", suffix: nil, updatedAt: nil)
        
        membershipCardStatusModel = MembershipCardStatusModel(apiId: 500, state: .authorised, reasonCodes: [.pointsScrapingLoginRequired])
        
        membershipCardResponse = MembershipCardModel(apiId: 500, membershipPlan: 500, membershipTransactions: nil, status: membershipCardStatusModel, card: cardResponse, images: nil, account: MembershipCardAccountModel(apiId: 500, tier: 1), paymentCards: nil, balances: [membershipCardBalanceModel], vouchers: [voucherResponse], openedTime: nil)
        
        mapResponseToManagedObject(membershipCardResponse, managedObjectType: CD_MembershipCard.self) { membershipCard in
            self.membershipCard = membershipCard
        }
        
        sut = AuthAndAddViewModel(membershipPlan: membershipPlan, formPurpose: .add, existingMembershipCard: membershipCard, prefilledFormValues: [FormDataSource.PrefilledValue(commonName: .email, value: "rick@mail.com")])
    }

    func test_accountButtonShouldHide() throws {
        Self.sut = AuthAndAddViewModel(membershipPlan: Self.membershipPlan, formPurpose: .ghostCard, existingMembershipCard: Self.membershipCard, prefilledFormValues: [FormDataSource.PrefilledValue(commonName: .email, value: "rick@mail.com")])
        
        XCTAssertTrue(Self.sut.accountButtonShouldHide)
    }
    
    func test_planDocumentDisplayMatching() throws {
        Self.sut = AuthAndAddViewModel(membershipPlan: Self.membershipPlan, formPurpose: .add, existingMembershipCard: Self.membershipCard, prefilledFormValues: [FormDataSource.PrefilledValue(commonName: .email, value: "rick@mail.com")])
        
        XCTAssertTrue(Self.sut.formPurpose.planDocumentDisplayMatching == PlanDocumentDisplayModel.add)
        
        Self.sut.formPurpose = .signUp
        XCTAssertTrue(Self.sut.formPurpose.planDocumentDisplayMatching == PlanDocumentDisplayModel.enrol)
        
        Self.sut.formPurpose = .ghostCard
        XCTAssertTrue(Self.sut.formPurpose.planDocumentDisplayMatching == PlanDocumentDisplayModel.registration)
    }
    
    func test_title_fromFormPurpose() throws {
        Self.sut = AuthAndAddViewModel(membershipPlan: Self.membershipPlan, formPurpose: .signUp, existingMembershipCard: Self.membershipCard, prefilledFormValues: [FormDataSource.PrefilledValue(commonName: .email, value: "rick@mail.com")])
        
        XCTAssertTrue(Self.sut.title == "Sign up for Test Plan")
        
        Self.sut.formPurpose = .add
        XCTAssertTrue(Self.sut.title == "Enter credentials")
        
        Self.sut.formPurpose = .addFailed
        XCTAssertTrue(Self.sut.title == "Log in")
        
        Self.sut.formPurpose = .ghostCard
        XCTAssertTrue(Self.sut.title == "Register your card")
    }
    
    func test_buttonTitle_fromFormPurpose() throws {
        Self.sut = AuthAndAddViewModel(membershipPlan: Self.membershipPlan, formPurpose: .signUp, existingMembershipCard: Self.membershipCard, prefilledFormValues: [FormDataSource.PrefilledValue(commonName: .email, value: "rick@mail.com")])
        
        XCTAssertTrue(Self.sut.title == "Sign up for Test Plan")
        
        Self.sut.formPurpose = .add
        XCTAssertTrue(Self.sut.title == "Enter credentials")
        
        Self.sut.formPurpose = .addFailed
        XCTAssertTrue(Self.sut.title == "Log in")
        
        Self.sut.formPurpose = .ghostCard
        XCTAssertTrue(Self.sut.title == "Register your card")
    }
    
    func test_getDescription_fromFormPurpose() throws {
        Self.sut = AuthAndAddViewModel(membershipPlan: Self.membershipPlan, formPurpose: .add, existingMembershipCard: Self.membershipCard, prefilledFormValues: [FormDataSource.PrefilledValue(commonName: .email, value: "rick@mail.com")])
        
        XCTAssertTrue(Self.sut.getDescription() == "Please enter your Tesco credentials below to add this card to your wallet.")
        
        Self.membershipPlanAccountModel.planSummary = nil
        Self.membershipPlanResponse.account = Self.membershipPlanAccountModel
        
        mapResponseToManagedObject(Self.membershipPlanResponse, managedObjectType: CD_MembershipPlan.self) { plan in
            Self.membershipPlan = plan
        }
        
        Self.sut = AuthAndAddViewModel(membershipPlan: Self.membershipPlan, formPurpose: .signUp, existingMembershipCard: Self.membershipCard, prefilledFormValues: [FormDataSource.PrefilledValue(commonName: .email, value: "rick@mail.com")])
        
        XCTAssertTrue(Self.sut.getDescription() == "Fill out the form below to get a new Card Name and start collecting rewards")
        
        Self.membershipPlanAccountModel.planSummary = "Summary"
        Self.membershipPlanResponse.account = Self.membershipPlanAccountModel
        
        mapResponseToManagedObject(Self.membershipPlanResponse, managedObjectType: CD_MembershipPlan.self) { plan in
            Self.membershipPlan = plan
        }
        
        Self.sut = AuthAndAddViewModel(membershipPlan: Self.membershipPlan, formPurpose: .signUp, existingMembershipCard: Self.membershipCard, prefilledFormValues: [FormDataSource.PrefilledValue(commonName: .email, value: "rick@mail.com")])
        
        XCTAssertTrue(Self.sut.getDescription() == "Summary")

        Self.sut.formPurpose = .ghostCard
        XCTAssertTrue(Self.sut.getDescription() == "Fill out the form below to get a new Card Name and start collecting rewards")
        
        Self.membershipPlanAccountModel.planRegisterInfo = "Register"
        Self.membershipPlanResponse.account = Self.membershipPlanAccountModel
        
        mapResponseToManagedObject(Self.membershipPlanResponse, managedObjectType: CD_MembershipPlan.self) { plan in
            Self.membershipPlan = plan
        }
        
        Self.sut = AuthAndAddViewModel(membershipPlan: Self.membershipPlan, formPurpose: .ghostCard, existingMembershipCard: Self.membershipCard, prefilledFormValues: [FormDataSource.PrefilledValue(commonName: .email, value: "rick@mail.com")])

        XCTAssertTrue(Self.sut.getDescription() == "Register")
    }
    
    func test_addMembershipCard_ghost() throws {
        Self.sut = AuthAndAddViewModel(membershipPlan: Self.membershipPlan, formPurpose: .ghostCard, existingMembershipCard: Self.membershipCard, prefilledFormValues: [FormDataSource.PrefilledValue(commonName: .email, value: "rick@mail.com")])
        
        let nameOnCardField = FormField(
            title: "Name on card",
            placeholder: "J Appleseed",
            validation: "^(((?=.{1,}$)[A-Za-z\\-\\u00C0-\\u00FF' ])+\\s*)$",
            fieldType: .text,
            updated: { field, newValue in },
            shouldChange: { (field, textField, range, newValue) in return false},
            fieldExited: { field in }
        )
        
        Current.apiClient.testResponseData = nil
        let model = MembershipCardPostModel(account: nil, membershipPlan: 500)
        let mocked = try! JSONEncoder().encode(Self.membershipCardResponse)

        let endpoint = APIEndpoint.membershipCard(cardId: Self.membershipCard.id).urlString!
        let mock = Mock(url: URL(string: endpoint)!, dataType: .json, statusCode: 200, data: [.patch: mocked])
        mock.register()
        
        var complete = false
        
        do {
            try Self.sut.addMembershipCard(with: [nameOnCardField], completion: {})
            complete = true
        } catch {
            complete = false
        }
        
        _ = XCTWaiter.wait(for: [self.expectation(description: "Wait for network call closure to complete")], timeout: 5.0)
        
        XCTAssertTrue(complete)
    }
    
    func test_brandHeaderTapped() {
        Self.sut = AuthAndAddViewModel(membershipPlan: Self.membershipPlan, formPurpose: .ghostCard, existingMembershipCard: Self.membershipCard, prefilledFormValues: [FormDataSource.PrefilledValue(commonName: .email, value: "rick@mail.com")])
        
        Self.sut.brandHeaderWasTapped()
        
        XCTAssertTrue(Current.navigate.currentViewController!.isKind(of: ReusableTemplateViewController.self))
    }
}
