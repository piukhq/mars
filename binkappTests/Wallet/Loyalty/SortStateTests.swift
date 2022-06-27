//
//  SortStateTests.swift
//  binkappTests
//
//  Created by Ricardo Silva on 27/06/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import XCTest
@testable import binkapp

class SortStateTests: XCTestCase {
    func test_sortStateIsNewest() throws {
        let loyaltyModel = LoyaltyWalletViewModel()
        loyaltyModel.setMembershipCardsSortingType(sortType: "Newest")
        let type = loyaltyModel.getCurrentMembershipCardsSortType()
        
        XCTAssertEqual(type, "Newest")
    }
    
    func test_sortStateIsCustom() throws {
        let loyaltyModel = LoyaltyWalletViewModel()
        loyaltyModel.setMembershipCardsSortingType(sortType: "Custom")
        let type = loyaltyModel.getCurrentMembershipCardsSortType()
        
        XCTAssertEqual(type, "Custom")
    }
}
