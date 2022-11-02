//
//  CAGradientLayerTests.swift
//  binkappTests
//
//  Created by Ricardo Silva on 02/11/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import XCTest
@testable import binkapp

// swiftlint:disable all

final class CAGradientLayerTests: XCTestCase {

    func test_canMakeGradients_AndRevomeGradients() throws {
        let gradient = CAGradientLayer.makeGradient(firstColor: .blue, secondColor: .red)
        
        XCTAssertNotNil(gradient)
        XCTAssertTrue(!gradient.colors!.isEmpty)
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        CAGradientLayer.makeGradient(for: view, firstColor: .red, secondColor: .blue)
        
        XCTAssertTrue(!view.layer.sublayers!.isEmpty)
        
        CAGradientLayer.removeGradientLayer(for: view)
        
        XCTAssertNil(view.layer.sublayers)
    }
}
