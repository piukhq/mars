//
//  LoyaltyCardFullDetailsViewControllerTests.swift
//  binkappTests
//
//  Created by Ricardo Silva on 17/11/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import XCTest
@testable import binkapp

// swiftlint:disable all

final class LoyaltyCardFullDetailsViewControllerTests: XCTestCase, CoreDataTestable {

    var model: LoyaltyCardFullDetailsViewModel!
    var membershipCard: CD_MembershipCard!
    var membershipPlan: CD_MembershipPlan!
    
    var paymentCardCardResponse: PaymentCardCardResponse!
    var basePaymentCardResponse: PaymentCardModel!
    var paymentCard: CD_PaymentCard!
    let linkedResponse = LinkedCardResponse(id: 300, activeLink: true)
    var sut: LoyaltyCardFullDetailsViewController!
    
    override func setUp() {
        super.setUp()
        
        let cardModel = CardModel(apiId: 300, barcode: "11111", membershipId: "1111", barcodeType: 1, colour: nil, secondaryColour: nil)
        
        let baseMembershipCardResponse = MembershipCardModel(apiId: 300, membershipPlan: 500, membershipTransactions: nil, status: nil, card: cardModel, images: nil, account: nil, paymentCards: nil, balances: nil, vouchers: nil, openedTime: nil)
        
        let featureSetResponse = FeatureSetModel(apiId: nil, authorisationRequired: nil, transactionsAvailable: nil, digitalOnly: nil, hasPoints: nil, cardType: .store, linkingSupport: nil, hasVouchers: true)
        let enrolField = EnrolFieldModel(apiId: nil, column: nil, validation: nil, fieldDescription: nil, type: nil, choices: [], commonName: nil)
        let planAccountResponse = MembershipPlanAccountModel(apiId: nil, planName: nil, planNameCard: nil, planURL: nil, companyName: "Tesco", category: nil, planSummary: nil, planDescription: nil, barcodeRedeemInstructions: nil, planRegisterInfo: nil, companyURL: nil, enrolIncentive: nil, forgottenPasswordUrl: nil, tiers: nil, planDocuments: nil, addFields: nil, authoriseFields: nil, registrationFields: nil, enrolFields: [enrolField])
        
        let membershipPlanResponse = MembershipPlanModel(apiId: 300, status: nil, featureSet: featureSetResponse, images: nil, account: planAccountResponse, balances: nil, dynamicContent: nil, hasVouchers: true, card: nil)
        
        paymentCardCardResponse = PaymentCardCardResponse(apiId: 100, firstSix: nil, lastFour: "1234", month: 30, year: 3000, country: nil, currencyCode: nil, nameOnCard: "Sean Williams", provider: nil, type: nil)
                
        basePaymentCardResponse = PaymentCardModel(apiId: 100, membershipCards: [linkedResponse], status: "active", card: paymentCardCardResponse, account: PaymentCardAccountResponse(apiId: 0, verificationInProgress: nil, status: 0, consents: []))
        
        mapResponseToManagedObject(basePaymentCardResponse, managedObjectType: CD_PaymentCard.self) { paymentCard in
            self.paymentCard = paymentCard
        }
        
        mapResponseToManagedObject(membershipPlanResponse, managedObjectType: CD_MembershipPlan.self) { plan in
            self.membershipPlan = plan
        }
        
        mapResponseToManagedObject(baseMembershipCardResponse, managedObjectType: CD_MembershipCard.self) { membershipCard in
            self.membershipCard = membershipCard
            self.membershipCard.membershipPlan = self.membershipPlan
        }
        
        addPaymentCardToWallet()
        
        let factory = WalletCardDetailInformationRowFactory()
        model = LoyaltyCardFullDetailsViewModel(membershipCard: membershipCard, informationRowFactory: factory)
        
        sut = LoyaltyCardFullDetailsViewController(viewModel: model)
        sut.viewDidLoad()
        sut.viewWillAppear(false)
        sut.viewDidAppear(false)
        sut.viewDidLayoutSubviews()
        sut.configureForCurrentTheme()
    }
    
    override func tearDown() {
        removePaymentCardFromWallet()
    }
    
    private func addPaymentCardToWallet() {
        Current.wallet.paymentCards = [paymentCard]
    }
    
    private func removePaymentCardFromWallet() {
        Current.wallet.paymentCards = []
    }
    
    func test_showBarCodeShouldBeVisible() throws {
        XCTAssertNotNil(sut.showBarcodeButton)
        XCTAssertTrue(sut.showBarcodeButton.currentTitle == "Tap to enlarge QR code")
    }
    
    /// RS - more to add here in the future
}
