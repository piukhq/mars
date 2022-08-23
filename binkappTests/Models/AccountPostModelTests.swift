//
//  AccountPostModelTests.swift
//  binkappTests
//
//  Created by Ricardo Silva on 23/08/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import XCTest
@testable import binkapp

// swiftlint:disable all

class AccountPostModelTests: XCTestCase {
    static var postModel: PostModel!
    static var accountPostModel: AccountPostModel!
    
    override class func setUp() {
        super.setUp()
        postModel = PostModel(column: "SomeColumn", value: "SomeValue")
        accountPostModel = AccountPostModel(addFields: [postModel], authoriseFields: [postModel], enrolFields: [postModel], registrationFields: [postModel])
    }
    
    private func setupWithFields() {
        Self.accountPostModel = AccountPostModel(addFields: [Self.postModel], authoriseFields: [Self.postModel], enrolFields: [Self.postModel], registrationFields: [Self.postModel])
        
    }
    
    private func clearFields() {
        Self.accountPostModel.addFields = nil
        Self.accountPostModel.authoriseFields = nil
        Self.accountPostModel.enrolFields = nil
        Self.accountPostModel.registrationFields = nil
    }
    
    func test_hasValidPayload() throws {
        setupWithFields()
        XCTAssertTrue(Self.accountPostModel.hasValidPayload)
    }
    
    func test_hasValidPayload_shouldBefalse() throws {
        clearFields()
        XCTAssertTrue(Self.accountPostModel.hasValidPayload)
    }
    
    func test_canAddFields_forTypes() throws {
        clearFields()
        
        Self.accountPostModel.addField(Self.postModel, to: MembershipAccountPostModelType.add)
        XCTAssertTrue(!Self.accountPostModel.addFields.isNilOrEmpty)
        
        Self.accountPostModel.addField(Self.postModel, to: MembershipAccountPostModelType.auth)
        XCTAssertTrue(!Self.accountPostModel.authoriseFields.isNilOrEmpty)
        
        Self.accountPostModel.addField(Self.postModel, to: MembershipAccountPostModelType.enrol)
        XCTAssertTrue(!Self.accountPostModel.enrolFields.isNilOrEmpty)
        
        Self.accountPostModel.addField(Self.postModel, to: MembershipAccountPostModelType.registration)
        XCTAssertTrue(!Self.accountPostModel.registrationFields.isNilOrEmpty)
    }
}
