//
//  FilterBrandsCollectionViewCellTests.swift
//  binkappTests
//
//  Created by Ricardo Silva on 03/11/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import XCTest
@testable import binkapp

// swiftlint:disable all

final class FilterBrandsCollectionViewCellTests: XCTestCase {

    func test_propertiesAreSetupCorrectly() throws {
        let cell: FilterBrandsCollectionViewCell = .fromNib()
        
        cell.configureCell(with: "Name")
        XCTAssertTrue(cell.getFilterTitleLabel().text == "Name")
        XCTAssertTrue(cell.getFilterTitleLabel().textColor == Current.themeManager.color(for: .text))
        XCTAssertTrue(cell.getCustomSeparatorView().backgroundColor == Current.themeManager.color(for: .divider))
        XCTAssertNotNil(cell.getImageView().image)
        
        cell.prepareForReuse()
        XCTAssertTrue(!cell.getCustomSeparatorView().isHidden)
        
        cell.hideSeparator()
        XCTAssertTrue(cell.getCustomSeparatorView().isHidden)
        
        cell.cellWasTapped = true
        XCTAssertTrue(cell.getImageView().tintColor == .binkDynamicGray2)
        
        cell.cellWasTapped = false
        XCTAssertTrue(cell.getImageView().tintColor == .blueAccent)
    }
}
