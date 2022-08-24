//
//  PLRCellViewModelTests.swift
//  binkappTests
//
//  Created by Ricardo Silva on 23/08/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import XCTest
@testable import binkapp

class PLRCellViewModelTests: XCTestCase, CoreDataTestable {
    static var voucherResponse: VoucherModel!
    static var voucher: CD_Voucher!
    static var model: PLRCellViewModel!
    
    override class func setUp() {
        super.setUp()
        
        let burnModel = VoucherBurnModel(apiId: nil, currency: nil, prefix: "£", suffix: "gift", value: 500, type: "voucher")
        let stampsVoucherEarnModel = VoucherEarnModel(apiId: nil, currency: nil, prefix: "£", suffix: "gift", type: .accumulator, targetValue: 600, value: 500)
        voucherResponse = VoucherModel(apiId: nil, state: .inProgress, code: "123456", barcode: nil, barcodeType: nil, headline: nil, subtext: nil, dateRedeemed: 1536080100, dateIssued: 3332020, expiryDate: 1535080100, earn: stampsVoucherEarnModel, burn: burnModel)
        
        mapResponseToManagedObject(Self.voucherResponse, managedObjectType: CD_Voucher.self) { voucher in
            self.voucher = voucher
        }
        
        model = PLRCellViewModel(voucher: voucher)
    }
    
    private func mapVoucher() {
        mapResponseToManagedObject(Self.voucherResponse, managedObjectType: CD_Voucher.self) { voucher in
            Self.voucher = voucher
        }
    }

    func test_voucherAmountText_ShouldBeValid_accumulator() throws {
        Self.voucherResponse.earn?.type = .accumulator
        mapVoucher()
        XCTAssertEqual(Self.model.voucherAmountText, "£500 gift voucher")
    }
    
    func test_voucherAmountText_ShouldBeValid_stamps() throws {
        Self.voucherResponse.earn?.type = .stamps
        mapVoucher()
        XCTAssertEqual(Self.model.voucherAmountText, "£500 gift")
    }
    
    func test_voucherDescriptionText_ShouldBeValid_accumulator() throws {
        Self.voucherResponse.earn?.type = .accumulator
        mapVoucher()
        XCTAssertEqual(Self.model.voucherDescriptionText, "for spending £600")
    }
    
    func test_voucherDescriptionText_ShouldBeValid_stamps() throws {
        Self.voucherResponse.earn?.type = .stamps
        Self.voucherResponse.state = .inProgress
        mapVoucher()
        XCTAssertEqual(Self.model.voucherDescriptionText, "for collecting £600 gift")
    }
    
    func test_headlineText_stamps_inProgress() throws {
        Self.voucherResponse.earn?.type = .stamps
        Self.voucherResponse.state = .inProgress
        mapVoucher()
        XCTAssertEqual(Self.model.headlineText, "£100 stamps to go!")
    }
    
    func test_headlineText_accumulator_issued() throws {
        Self.voucherResponse.earn?.type = .accumulator
        Self.voucherResponse.state = .issued
        mapVoucher()
        XCTAssertEqual(Self.model.headlineText, L10n.plrIssuedHeadline)
    }
    
    func test_headlineText_accumulator_expired() throws {
        Self.voucherResponse.earn?.type = .accumulator
        Self.voucherResponse.state = .expired
        mapVoucher()
        XCTAssertEqual(Self.model.headlineText, "Expired")
    }
    
    func test_ammountAccumulatedIsCorrect() throws {
        let value = String(format: "%.2f", Self.model.amountAccumulated)
        XCTAssertEqual(value, "0.83")
    }
    
    func test_stampsCollectedIsCorrect() throws {
        XCTAssertEqual(Self.model.stampsCollected, 500)
    }
    
    func test_stampsAvailableIsCorrect() throws {
        XCTAssertEqual(Self.model.stampsAvailable, 600)
    }
    
    func test_shouldReturnCorrect_earnProgressString() throws {
        Self.voucherResponse.earn?.type = .accumulator
        mapVoucher()
        XCTAssertEqual(Self.model.earnProgressString, L10n.plrVoucherAccumulatorEarnValueTitle)
        
        Self.voucherResponse.earn?.type = .stamps
        mapVoucher()
        XCTAssertEqual(Self.model.earnProgressString, L10n.plrVoucherStampEarnValueTitle)
    }
    
    func test_shouldReturnCorrect_earnProgressValueString() throws {
        Self.voucherResponse.earn?.type = .accumulator
        mapVoucher()
        XCTAssertEqual(Self.model.earnProgressValueString, "£500.00 gift")
        
        Self.voucherResponse.earn?.type = .stamps
        mapVoucher()
        XCTAssertEqual(Self.model.earnProgressValueString, "500/600 gift")
    }
    
    func test_shouldReturnCorrect_earnTargetString() throws {
        Self.voucherResponse.earn?.type = .accumulator
        mapVoucher()
        XCTAssertEqual(Self.model.earnTargetString, L10n.plrVoucherEarnTargetValueTitle)
        
        Self.voucherResponse.earn?.type = .stamps
        mapVoucher()
        XCTAssertEqual(Self.model.earnTargetString, "")
    }
    
    func test_shouldReturnCorrect_earnTargetValueString() throws {
        Self.voucherResponse.earn?.type = .accumulator
        mapVoucher()
        XCTAssertEqual(Self.model.earnTargetValueString, "£600.00 gift")
        
        Self.voucherResponse.earn?.type = .stamps
        mapVoucher()
        XCTAssertEqual(Self.model.earnTargetValueString, nil)
    }
    
    func test_shouldReturnCorrect_dateText_expired() throws {
        Self.voucherResponse.state = .expired
        mapVoucher()
        XCTAssertEqual(Self.model.dateText, "on 24 Aug 2018")
    }
    
    func test_shouldReturnCorrect_dateText_cancelled() throws {
        Self.voucherResponse.state = .cancelled
        mapVoucher()
        XCTAssertEqual(Self.model.dateText, "on 24 Aug 2018")
    }
    
    func test_shouldReturnCorrect_dateText_redeemed() throws {
        Self.voucherResponse.state = .redeemed
        mapVoucher()
        XCTAssertEqual(Self.model.dateText, "on 04 Sep 2018")
    }
    
    func test_shouldReturnCorrect_dateText_should_be_nil() throws {
        Self.voucherResponse.state = .inProgress
        mapVoucher()
        XCTAssertEqual(Self.model.dateText, nil)
    }
}
