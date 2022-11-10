//
//  ActivityViewControllerRepresentableTests.swift
//  binkappTests
//
//  Created by Ricardo Silva on 02/11/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import XCTest
@testable import binkapp
import LinkPresentation
// swiftlint:disable all

final class ActivityViewControllerRepresentableTests: XCTestCase {
    static var linkedDataManager: LinkMetadataManager!
    
    func test_linkedDataSetsUpCorrrectly() throws {
        Self.linkedDataManager = LinkMetadataManager(title: "linked", url: URL(string: "http://apple.com")!)
        
        XCTAssertTrue(Self.linkedDataManager.linkMetadata.isKind(of: LPLinkMetadata.self))
        XCTAssertTrue(Self.linkedDataManager.url.absoluteString == "http://apple.com")
        XCTAssertTrue(Self.linkedDataManager.title == "linked")
        
        let metadata = Self.linkedDataManager.activityViewControllerLinkMetadata( UIActivityViewController.init(activityItems: [], applicationActivities: nil))
        
        XCTAssertTrue(metadata!.url!.absoluteString == "http://apple.com")
        XCTAssertTrue(metadata!.title == "linked")
        
        let placeholder = Self.linkedDataManager.activityViewControllerPlaceholderItem(UIActivityViewController.init(activityItems: [], applicationActivities: nil))
        
        XCTAssertTrue(placeholder as! String == "")
        
        let activityType = Self.linkedDataManager.activityViewController(UIActivityViewController.init(activityItems: [], applicationActivities: nil), itemForActivityType: nil) as! URL
        
        XCTAssertTrue(activityType.absoluteString == "http://apple.com")
    }
}
