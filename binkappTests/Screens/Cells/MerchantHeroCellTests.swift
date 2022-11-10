//
//  MerchantHeroCellTests.swift
//  binkappTests
//
//  Created by Ricardo Silva on 26/10/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import XCTest
@testable import binkapp
// swiftlint:disable all

final class MerchantHeroCellTests: XCTestCase, CoreDataTestable {

    static var membershipPlan: CD_MembershipPlan!
    static var membershipPlanResponse: MembershipPlanModel!
    static var membershipPlanAccountModel: MembershipPlanAccountModel!
    
    static var cardResponse: CardModel!
    
    override class func setUp() {
        super.setUp()
        
        cardResponse = CardModel(apiId: nil, barcode: "123456789", membershipId: "999 666", barcodeType: 0, colour: "#0000ff", secondaryColour: nil)
        
        let featureSet = FeatureSetModel(apiId: nil, authorisationRequired: nil, transactionsAvailable: nil, digitalOnly: nil, hasPoints: nil, cardType: .link, linkingSupport: [.add], hasVouchers: nil)
        
        membershipPlanAccountModel = MembershipPlanAccountModel(apiId: nil, planName: "Test Plan", planNameCard: nil, planURL: nil, companyName: "Tesco", category: nil, planSummary: nil, planDescription: nil, barcodeRedeemInstructions: nil, planRegisterInfo: nil, companyURL: nil, enrolIncentive: nil, forgottenPasswordUrl: nil, tiers: nil, planDocuments: nil, addFields: nil, authoriseFields: nil, registrationFields: nil, enrolFields: nil)
        
        membershipPlanResponse = MembershipPlanModel(apiId: 500, status: nil, featureSet: featureSet, images: nil, account: membershipPlanAccountModel, balances: nil, dynamicContent: nil, hasVouchers: nil, card: cardResponse)
        
        mapResponseToManagedObject(membershipPlanResponse, managedObjectType: CD_MembershipPlan.self) { plan in
            self.membershipPlan = plan
        }
    }
    
    func test_cell_returnsCorrectIdentifier() throws {
        let cell = MerchantHeroCell()
        
        XCTAssertTrue(cell.reuseIdentifier == "MerchantHeroCell")
    }
    
    func test_bg_colour_is_placeholder() throws {
        let cell = MerchantHeroCell()
        cell.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        
        cell.configure(with: Self.membershipPlan, walletPrompt: WalletPrompt(type: .link(plans: [Self.membershipPlan])), showMorePlansCell: false, indexPath: IndexPath(row: 0, section: 0))
        
        XCTAssertTrue(cell.backgroundColor?.cgColor.components![0] == 1.0)
    }
    
    func test_bg_colour_showMorePlansCells() throws {
        let cell = MerchantHeroCell()
        cell.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        
        cell.configure(with: Self.membershipPlan, walletPrompt: WalletPrompt(type: .addPaymentCards), showMorePlansCell: true, indexPath: IndexPath(row: 0, section: 0))
        
        XCTAssertTrue(cell.backgroundColor == .binkDynamicGray2)
    }
    
    func test_bg_colour_noMorePlansCells() throws {
        let cell = MerchantHeroCell()
        cell.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        
        cell.configure(with: Self.membershipPlan, walletPrompt: WalletPrompt(type: .addPaymentCards), showMorePlansCell: false, indexPath: IndexPath(row: 0, section: 0))
        
        XCTAssertTrue(cell.backgroundColor == .clear)
    }
    
    func test_imageViewIsValid() throws {
        let cell = MerchantHeroCell()
        cell.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        
        cell.configure(with: Self.membershipPlan, walletPrompt: WalletPrompt(type: .link(plans: [Self.membershipPlan])), showMorePlansCell: false, indexPath: IndexPath(row: 0, section: 0))
        
        XCTAssertNotNil(cell.subviews[0])
    }
    
    func test_imageView_hasCorrectProperties_showMorePlansCells() throws {
        let cell = MerchantHeroCell()
        cell.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        
        cell.configure(with: Self.membershipPlan, walletPrompt: WalletPrompt(type: .addPaymentCards), showMorePlansCell: true, indexPath: IndexPath(row: 0, section: 0))
        
        let imageView = cell.subviews[0] as! UIImageView
        XCTAssertTrue(imageView.tintColor == .white)
        XCTAssertNotNil(imageView.image)
    }
    
    func test_imageView_hasCorrectProperties_noMorePlansCells() throws {
        let cell = MerchantHeroCell()
        cell.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        
        cell.configure(with: Self.membershipPlan, walletPrompt: WalletPrompt(type: .addPaymentCards), showMorePlansCell: false, indexPath: IndexPath(row: 0, section: 0))
        
        let imageView = cell.subviews[0] as! UIImageView
        XCTAssertTrue(imageView.contentMode == .scaleAspectFill)
        XCTAssertTrue(imageView.layer.cornerRadius == 10)
        XCTAssertTrue(imageView.layer.cornerCurve == .continuous)
        XCTAssertTrue(imageView.clipsToBounds == true)
    }
    
    func test_placeholder_hasCorrectProperties() throws {
        let cell = MerchantHeroCell()
        cell.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        
        cell.configureWithPlaceholder(walletPrompt: WalletPrompt(type: .link(plans: [Self.membershipPlan])))
        
        let label = cell.subviews[0] as! UILabel
        
        XCTAssertTrue(Int(label.frame.width) == 170)
        XCTAssertTrue(Int(label.frame.height) == 101)
    }
}
