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
    
    private func getKeyWindow() {
        if let window = UIApplication.shared.connectedScenes.flatMap({ ($0 as? UIWindowScene)?.windows ?? [] }).first(where: { $0.isKeyWindow }) {
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
        MessageView.show("", type: .snackbar(.short))
        getKeyWindow()
        XCTAssertEqual(sut.getType().hideOffset, window.bounds.height + 100)
        
        sut.removeFromSuperview()
        
        MessageView.show("", type: .responseCodeVisualizer(.success))
        getKeyWindow()
        XCTAssertEqual(sut.getType().hideOffset, -50)
        sut.removeFromSuperview()
    }
    
//    func test_textColor_returnsCorrectColor() {
//        MessageView.show("", type: .snackbar(.long), button: MessageButton(title: "", type: .success, action: {}))
//        getKeyWindow()
//
//        if let button = sut.getMessageButton() {
//            XCTAssertEqual(button.textColor, .greenOk)
//        } else {
//            XCTFail("GreenOK: Message button is nil")
//        }
//
//        sut.removeFromSuperview()
//
//        MessageView.show("", type: .snackbar(.long), button: MessageButton(title: "", type: .error, action: {}))
//        getKeyWindow()
//
//        if let button = sut.getMessageButton() {
//            XCTAssertEqual(button.textColor, .binkDynamicRed)
//        } else {
//            XCTFail("Red: Message button is nil")
//        }
//
//        sut.removeFromSuperview()
//    }
    
    func test_hide_correctlyAdjustsViewPosition() {
        MessageView.show("", type: .responseCodeVisualizer(.success))
        getKeyWindow()
        
        let exp = expectation(description: "Wait for Hide to be called after delay")
        let result = XCTWaiter.wait(for: [exp], timeout: 3.5)
        if result == XCTWaiter.Result.timedOut {
            XCTAssertTrue(self.sut.frame.maxY == 20)
        } else {
            XCTFail("Delay interrupted")
        }
        
        sut.removeFromSuperview()
    }
    
    func test_hideSideways_correctlyAdjustsViewPosition() {
        MessageView.show("", type: .responseCodeVisualizer(.success))
        getKeyWindow()
        MessageView.show("", type: .responseCodeVisualizer(.success))

        let exp = expectation(description: "Wait for Hide sideways to be called after delay")
        let result = XCTWaiter.wait(for: [exp], timeout: 3.5)
        if result == XCTWaiter.Result.timedOut {
            XCTAssertTrue(self.sut.frame.minX == -500)
        } else {
            XCTFail("Delay interrupted")
        }
        
        sut.removeFromSuperview()
    }
}
