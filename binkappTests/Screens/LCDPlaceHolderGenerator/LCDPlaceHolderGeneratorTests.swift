//
//  LCDPlaceHolderGeneratorTests.swift
//  binkappTests
//
//  Created by Ricardo Silva on 19/08/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import XCTest
import UIKit

@testable import binkapp

class LCDPlaceHolderGeneratorTests: XCTestCase {   
    func test_Example() throws {
        let image = LCDPlaceholderGenerator.generate(with: "#008233", planName: "place holder", destSize: CGSize(width: 100, height: 100), font: .textFieldLabel)
        
        XCTAssertNotNil(image)
    }
    
    func test_generatWithPlanName() throws {
        let iconImage = Asset.iconCheck.image
        
        let image = LCDPlaceholderGenerator.generate(with: "place holder", iconImage: iconImage, destSize: CGSize(width: 100, height: 100))
        XCTAssertNotNil(image)
    }
}
