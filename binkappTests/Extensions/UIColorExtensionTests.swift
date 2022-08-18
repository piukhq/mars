//
//  UIColorExtensionTests.swift
//  binkappTests
//
//  Created by Ricardo Silva on 17/08/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

// swiftlint:disable all

import XCTest
import UIKit

@testable import binkapp

class UIColorExtensionTests: XCTestCase {
    func test_ColoursToHexValue() throws {
        let hexRed = UIColor.red.toHexString()
        let hexBlue = UIColor.blue.toHexString()
        XCTAssertTrue(hexRed == "#ff0000")
        XCTAssertTrue(hexBlue == "#0000ff")
    }
    
    func test_colorShouldBeBinkPurple() throws {
        let color = UIColor.binkPurple
       
        XCTAssertTrue(color.cgColor.components![0] == 180 / 255)
        XCTAssertTrue(color.cgColor.components![1] == 111 / 255)
        XCTAssertTrue(color.cgColor.components![2] == 234 / 255)
        XCTAssertTrue(color.cgColor.components![3] == 1)
    }
    
    func test_colorShouldBeGreenOk() throws {
        let color = UIColor.greenOk
       
        XCTAssertTrue(color.cgColor.components![0] == 0 / 255)
        XCTAssertTrue(color.cgColor.components![1] == 193 / 255)
        XCTAssertTrue(color.cgColor.components![2] == 118 / 255)
        XCTAssertTrue(color.cgColor.components![3] == 1)
    }
    
    func test_colorShouldBeBlueInactive() throws {
        let color = UIColor.blueInactive
       
        XCTAssertTrue(color.cgColor.components![0] == 177 / 255)
        XCTAssertTrue(color.cgColor.components![1] == 194 / 255)
        XCTAssertTrue(color.cgColor.components![2] == 203 / 255)
        XCTAssertTrue(color.cgColor.components![3] == 1)
    }
    
    func test_colorShouldBeGreyFifty() throws {
        let color = UIColor.greyFifty
       
        XCTAssertTrue(color.cgColor.components![0] == 127 / 255)
        XCTAssertTrue(color.cgColor.components![1] == 127 / 255)
        XCTAssertTrue(color.cgColor.components![2] == 127 / 255)
        XCTAssertTrue(color.cgColor.components![3] == 1)
    }
    
    func test_colorShouldBesSortBarButton() throws {
        let color = UIColor.sortBarButton
       
        XCTAssertTrue(color.cgColor.components![0] == 177 / 255)
        XCTAssertTrue(color.cgColor.components![1] == 194 / 255)
        XCTAssertTrue(color.cgColor.components![2] == 203 / 255)
        XCTAssertTrue(color.cgColor.components![3] == 1)
    }
    
    func test_isColorLight() throws {
        let color = UIColor.white
        XCTAssertTrue(color.isLight())
    }
    
    func test_isColorDark() throws {
        let color = UIColor.black
        XCTAssertTrue(!color.isLight())
    }
    
    func test_color50PercentDarker() throws {
        let color = UIColor.white.darker(by: 50)
        XCTAssertTrue(color!.cgColor.components![0] == 127.5 / 255)
        XCTAssertTrue(color!.cgColor.components![1] == 127.5 / 255)
        XCTAssertTrue(color!.cgColor.components![2] == 127.5 / 255)
    }
    
    func test_color50PercentLighter() throws {
        let color = UIColor.black.lighter(by: 50)
        XCTAssertTrue(color!.cgColor.components![0] == 127.5 / 255)
        XCTAssertTrue(color!.cgColor.components![1] == 127.5 / 255)
        XCTAssertTrue(color!.cgColor.components![2] == 127.5 / 255)
    }
    
    func test_binkGreyDynamic_light() throws {
        let theme = Theme(type: .light)
        Current.themeManager.setTheme(theme)
        
        let color = UIColor.binkDynamicGray
        XCTAssertEqual(color, UIColor.binkDynamicGrayLight)
    }
    
    func test_binkGreyDynamic_dark() throws {
        let theme = Theme(type: .dark)
        Current.themeManager.setTheme(theme)
        
        let color = UIColor.binkDynamicGray
        XCTAssertEqual(color, UIColor.binkBlueDivider)
    }
    
    func test_binkDynamicGray2_light() throws {
        let theme = Theme(type: .light)
        Current.themeManager.setTheme(theme)
        
        let color = UIColor.binkDynamicGray2
        XCTAssertEqual(color, UIColor.binkDynamicGrayLight)
    }
    
    func test_bingGreyDynamic2_dark() throws {
        let theme = Theme(type: .dark)
        Current.themeManager.setTheme(theme)
        
        let color = UIColor.binkDynamicGray2
        XCTAssertEqual(color, UIColor.binkDynamicGrayDark)
    }
    
    func test_binkDynamicGray3_light() throws {
        let theme = Theme(type: .light)
        Current.themeManager.setTheme(theme)
        
        let color = UIColor.binkDynamicGray3
        XCTAssertEqual(color, UIColor.darkGray)
    }
    
    func test_bingGreyDynamic3_dark() throws {
        let theme = Theme(type: .dark)
        Current.themeManager.setTheme(theme)
        
        let color = UIColor.binkDynamicGray3
        XCTAssertEqual(color, UIColor.binkDynamicGrayLight)
    }
    
    func test_binkDynamicRed_light() throws {
        let theme = Theme(type: .light)
        Current.themeManager.setTheme(theme)
        
        let color = UIColor.binkDynamicRed
        XCTAssertEqual(color, UIColor(hexString: "FF0000"))
    }
    
    func test_bingDynamicRed_dark() throws {
        let theme = Theme(type: .dark)
        Current.themeManager.setTheme(theme)
        
        let color = UIColor.binkDynamicRed
        XCTAssertEqual(color, UIColor(hexString: "ff453a"))
    }
}
