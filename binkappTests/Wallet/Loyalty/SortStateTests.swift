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
        loyaltyModel.setMembershipCardsSortingType(sortType: .newest)
        let type = loyaltyModel.getCurrentMembershipCardsSortType()?.rawValue
        
        XCTAssertEqual(type, "Newest")
    }
    
    func test_sortStateIsCustom() throws {
        let loyaltyModel = LoyaltyWalletViewModel()
        loyaltyModel.setMembershipCardsSortingType(sortType: .custom)
        let type = loyaltyModel.getCurrentMembershipCardsSortType()?.rawValue
        
        XCTAssertEqual(type, "Custom")
    }
}
