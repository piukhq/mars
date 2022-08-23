//
//  VoucherModelTests.swift
//  binkappTests
//
//  Created by Ricardo Silva on 21/08/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import XCTest
@testable import binkapp

// swiftlint:disable all

class VoucherModelTests: XCTestCase {
    static var voucherModel: VoucherModel!
    
    override class func setUp() {
        super.setUp()
        voucherModel = VoucherModel(apiId: nil, state: .issued, code: "123456", barcode: nil, barcodeType: nil, headline: nil, subtext: nil, dateRedeemed: 1536080100, dateIssued: 3332020, expiryDate: 1535080100, earn: nil, burn: nil)
    }
    
    func test_sort_issued() throws {
        Self.voucherModel.state = .issued
        XCTAssertEqual(Self.voucherModel.state!.sort, 0)
    }
    
    func test_sort_inProgress() throws {
        Self.voucherModel.state = .inProgress
        XCTAssertEqual(Self.voucherModel.state!.sort, 1)
    }
    
    func test_sort_redeeemed() throws {
        Self.voucherModel.state = .redeemed
        XCTAssertEqual(Self.voucherModel.state!.sort, 2)
    }
    
    func test_sort_expired() throws {
        Self.voucherModel.state = .expired
        XCTAssertEqual(Self.voucherModel.state!.sort, 2)
    }
    
    func test_sort_cancelled() throws {
        Self.voucherModel.state = .cancelled
        XCTAssertEqual(Self.voucherModel.state!.sort, 2)
    }
}
