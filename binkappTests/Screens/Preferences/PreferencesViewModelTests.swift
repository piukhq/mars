//
//  PreferencesViewModelTests.swift
//  binkappTests
//
//  Created by Ricardo Silva on 27/10/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import XCTest
import Mocker
@testable import binkapp

// swiftlint:disable all

final class PreferencesViewModelTests: XCTestCase {

    static var sut: PreferencesViewModel!
    
    override class func setUp() {
        super.setUp()
        
        sut = PreferencesViewModel()
    }

    func test_descriptionTextIsCorrect() throws {
        let text = NSAttributedString(Self.sut.descriptionText)
        XCTAssertTrue(text.string == "Make sure you’re the first to know about available rewards, offers and updates!")
    }
    
    func test_getPreferences() throws {
        Current.apiClient.testResponseData = nil
        let preferencesModel = [PreferencesModel(isUserDefined: true, user: 1, value: "0", slug: "marketing", defaultValue: "0", valueType: "boolean", scheme: nil, label: "Marketing Bink", category: "marketing")]
        let mocked = try! JSONEncoder().encode(preferencesModel)
        
        let mock = Mock(url: URL(string: APIEndpoint.preferences.urlString!)!, dataType: .json, statusCode: 200, data: [.get: mocked])
        mock.register()
        
        Self.sut.getPreferences()
        
        _ = XCTWaiter.wait(for: [self.expectation(description: "Wait for network call closure to complete")], timeout: 5.0)
        
        XCTAssertTrue(!Self.sut.checkboxViewModels.isEmpty)
    }
    
    func test_putPreferences() throws {
        Current.apiClient.testResponseData = nil
        
        let mock = Mock(url: URL(string: APIEndpoint.preferences.urlString!)!, dataType: .json, statusCode: 200, data: [.put: Data()])
        mock.register()
        
        var complete = false
        let pref = ["Pref": "test"]
        Self.sut.setPreferences(params: pref, completion: {success,_ in
            complete = success
        })
        
        _ = XCTWaiter.wait(for: [self.expectation(description: "Wait for network call closure to complete")], timeout: 5.0)
        
        XCTAssertTrue(complete)
    }
    
    func test_connectivityPopup() throws {
        Self.sut.presentNoConnectivityPopup()
        
        XCTAssertTrue(Current.navigate.currentViewController!.isKind(of: BinkAlertController.self))
    }
    
    func test_clearStoredCredentials() throws {
        Self.sut.clearStoredCredentials()
        
        XCTAssertTrue(Current.navigate.currentViewController!.isKind(of: BinkAlertController.self))
    }
    
    func test_checkboxViewWasToggled() throws {
        Current.apiClient.testResponseData = nil
        
        let mock = Mock(url: URL(string: APIEndpoint.preferences.urlString!)!, dataType: .json, statusCode: 200, data: [.put: Data()])
        mock.register()
        
        Self.sut.checkboxViewWasToggled(CheckboxViewModel(checkedState: false, columnName: "remember-my-details", columnKind: FormField.ColumnKind.none))
        
        XCTAssertTrue(Current.navigate.currentViewController!.isKind(of: BinkAlertController.self))
    }
    
    func test_configureUserPreferenceFromAPI() throws {
        Current.apiClient.testResponseData = nil
        let preferencesModel = [PreferencesModel(isUserDefined: true, user: 1, value: "1", slug: "show-barcode-always", defaultValue: "0", valueType: "boolean", scheme: nil, label: "Marketing Bink", category: "marketing")]
        let mocked = try! JSONEncoder().encode(preferencesModel)
        
        let mock = Mock(url: URL(string: APIEndpoint.preferences.urlString!)!, dataType: .json, statusCode: 200, data: [.get: mocked])
        mock.register()
        
        Self.sut.configureUserPreferenceFromAPI()
        
        _ = XCTWaiter.wait(for: [self.expectation(description: "Wait for network call closure to complete")], timeout: 5.0)
        
        XCTAssertTrue(Current.userDefaults.bool(forDefaultsKey: .showBarcodeAlways))
    }
}
