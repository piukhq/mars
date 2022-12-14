//
//  BinkSwitchTests.swift
//  binkappTests
//
//  Created by Ricardo Silva on 26/10/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import XCTest
@testable import binkapp

// swiftlint:disable all

final class BinkSwitchTests: XCTestCase {
    
    func test_hasGradient() throws {
        let binkSwitch = BinkSwitch()
        binkSwitch.isOn = true
        
        let g1 = binkSwitch.layer.sublayers?.first
        XCTAssertTrue(g1!.isKind(of: CAGradientLayer.self))
        
        binkSwitch.isOn = false
        let g2 = binkSwitch.layer.sublayers?.first
        XCTAssertTrue(g2!.isKind(of: CALayer.self))
    }
    
    func test_gradientVisibility() throws {
        let binkSwitch = BinkSwitch()
        
        binkSwitch.isGradientVisible = true
        
        let g1 = binkSwitch.layer.sublayers?.first
        XCTAssertTrue(g1!.isKind(of: CAGradientLayer.self))
        
        binkSwitch.isGradientVisible = false
        let g2 = binkSwitch.layer.sublayers?.first
        XCTAssertTrue(g2!.isKind(of: CALayer.self))
    }
    
    func test_gradientHasCorrectColor() throws {
        let binkSwitch = BinkSwitch()
        binkSwitch.layoutSubviews()
        binkSwitch.isOn = true
        
        let gradient = binkSwitch.layer.sublayers?.first as! CAGradientLayer
        XCTAssertTrue(gradient.colors![0] as! CGColor == UIColor.binkGradientBlueLeft.cgColor)
        XCTAssertTrue(gradient.colors![1] as! CGColor == UIColor.binkGradientBlueRight.cgColor)
    }
}
