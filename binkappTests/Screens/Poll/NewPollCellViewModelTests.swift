//
//  NewPollCellViewModelTests.swift
//  binkappTests
//
//  Created by Ricardo Silva on 22/06/2023.
//  Copyright © 2023 Bink. All rights reserved.
//

import XCTest
@testable import binkapp

import SwiftUI

// swiftlint:disable all

final class NewPollCellViewModelTests: XCTestCase {

    var sut = NewPollCellViewModel(firestoreManager: FirestoreMock())

    func test_pollDataIsValid() throws {
        Current.userDefaults.set(nil, forDefaultsKey: .timeToPromptPollRemindDate)
        Current.userDefaults.set(false, forDefaultsKey: .isInPollRemindPeriod)
        XCTAssertNotNil(sut.pollData)
    }
    
    func test_dismissPollPressed_settingsAreCorrect() throws {
        Current.userDefaults.set(nil, forDefaultsKey: .timeToPromptPollRemindDate)
        Current.userDefaults.set(false, forDefaultsKey: .isInPollRemindPeriod)
        
        sut.dismissPollPressed()

        let value = Current.userDefaults.string(forDefaultsKey: .dismissedPollId)
        XCTAssertEqual(value, "10")
    }
    
    func test_remindLaterPressed_settingsAreCorrect() throws {
        Current.userDefaults.set(nil, forDefaultsKey: .timeToPromptPollRemindDate)
        Current.userDefaults.set(false, forDefaultsKey: .isInPollRemindPeriod)
        
        sut.remindLaterPressed()
        XCTAssertTrue(Current.userDefaults.bool(forDefaultsKey: .isInPollRemindPeriod))

        XCTAssertNotNil(Current.userDefaults.value(forDefaultsKey: .timeToPromptPollRemindDate))
    }
}
