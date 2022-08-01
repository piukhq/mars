//
//  MessageViewTests.swift
//  binkappTests
//
//  Created by Sean Williams on 01/08/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import XCTest
@testable import binkapp

class MessageViewTests: XCTestCase {
    var sut: MessageView!
    var window: UIWindow!
    
    override func setUp() {
        super.setUp()
    }
    
    private func getKeyWindow() {
        if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
            if let messageView = window.subviews.first(where: { $0.isKind(of: MessageView.self) }) as? MessageView {
                sut = messageView
                self.window = window
            } else {
                XCTFail("Failed to get message view")
            }
        } else {
            XCTFail("Failed to get window")
        }
    }
    
    func test_hideOffset_returnsCorrectValue() {
        MessageView.show("Bello", type: .snackbar(.short))
        getKeyWindow()
        XCTAssertEqual(sut.type.hideOffset, window.bounds.height + 100)
        
        sut.removeFromSuperview()
        
        MessageView.show("Bello", type: .responseCodeVisualizer(.success))
        getKeyWindow()
        XCTAssertEqual(sut.type.hideOffset, -50)
    }
    
//    func test_textColor_returnsCorrectColor() {
//        MessageView.show("Bello", type: .snackbar(.short))
//        getKeyWindow()
//        XCTAssertEqual(sut.type.hideOffset, window.bounds.height + 100)
//        
//        sut.removeFromSuperview()
//        
//        MessageView.show("Bello", type: .responseCodeVisualizer(.success))
//        getKeyWindow()
//        XCTAssertEqual(sut.type.hideOffset, -50)
//    }
}
