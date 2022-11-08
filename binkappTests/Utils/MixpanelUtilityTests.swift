//
//  MixpanelUtilityTests.swift
//  binkappTests
//
//  Created by Ricardo Silva on 28/10/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import XCTest
@testable import binkapp

// swiftlint:disable all

final class MixpanelUtilityTests: XCTestCase {

    func test_mixpanelTrackableEvent_correctStrings() throws {
        var event = MixpanelTrackableEvent.loyaltyCardAdd(brandName: "Doom")
        XCTAssertTrue(event.identifier == "Loyalty card add")
        
        event = MixpanelTrackableEvent.loyaltyCardAddFailure(brandName: "Doom", reason: "Rip and tear")
        XCTAssertTrue(event.identifier == "Loyalty card add failed")
        
        event = MixpanelTrackableEvent.loyaltyCardDeleted(brandName: "Doom", route: .lcd)
        XCTAssertTrue(event.identifier == "Loyalty card deleted")
        
        event = MixpanelTrackableEvent.lcdViewed(brandName: "Doom", route: .lcd)
        XCTAssertTrue(event.identifier == "Loyalty card detail viewed")
        
        event = MixpanelTrackableEvent.loyaltyCardManuallyReordered(brandName: "Doom", originalIndex: 0, destinationIndex: 1)
        XCTAssertTrue(event.identifier == "Loyalty card manually reordered")
        
        event = MixpanelTrackableEvent.localPointsCollectionSuccess(brandName: "Doom")
        XCTAssertTrue(event.identifier == "Local points collection succeeded")
        
        event = MixpanelTrackableEvent.localPointsCollectionFailure(brandName: "Doom", reason: "error", underlyingError: "error")
        XCTAssertTrue(event.identifier == "Local points collection failed")
        
        event = MixpanelTrackableEvent.onboardingStart(route: .magicLink)
        XCTAssertTrue(event.identifier == "Onboarding start")
        
        event = MixpanelTrackableEvent.onboardingComplete(route: .magicLink)
        XCTAssertTrue(event.identifier == "Onboarding complete")
        
        event = MixpanelTrackableEvent.onboardingCarouselSwipe
        XCTAssertTrue(event.identifier == "Onboarding carousel swipe")
        
        event = MixpanelTrackableEvent.forgottenPassword
        XCTAssertTrue(event.identifier == "Forgotten password")
        
        event = MixpanelTrackableEvent.logout
        XCTAssertTrue(event.identifier == "User logged out")
        
        event = MixpanelTrackableEvent.viewBarcode(brandName: "Doom", route: .lcd)
        XCTAssertTrue(event.identifier == "Barcode viewed")
        
        event = MixpanelTrackableEvent.barcodeScreenIssueReported(brandName: "Doom", reason: .barcodeWontScan)
        XCTAssertTrue(event.identifier == "Barcode screen issue reported")
        
        event = MixpanelTrackableEvent.toLocations(brandName: "Doom")
        XCTAssertTrue(event.identifier == "Tapped Show Locations")
        
        event = MixpanelTrackableEvent.toAppleMaps(brandName: "Doom")
        XCTAssertTrue(event.identifier == "Launch Apple Maps for Directions")
        
        event = MixpanelTrackableEvent.toGoogleMaps(brandName: "Doom")
        XCTAssertTrue(event.identifier == "Launch Google Maps for Directions")
    }
    
    func test_mixpanelTrackableEvent_correctData() throws {
        var event = MixpanelTrackableEvent.loyaltyCardAdd(brandName: "Doom")
        XCTAssertTrue(event.data!["Brand name"] as! String == "Doom")
        
        event = MixpanelTrackableEvent.loyaltyCardAddFailure(brandName: "Doom", reason: "Rip and tear")
        XCTAssertTrue(event.data!["Brand name"] as! String == "Doom")
        XCTAssertTrue(event.data!["Reason"] as! String == "Rip and tear")
        
        event = MixpanelTrackableEvent.loyaltyCardDeleted(brandName: "Doom", route: .lcd)
        XCTAssertTrue(event.data!["Brand name"] as! String == "Doom")
        XCTAssertTrue(event.data!["Route"] as! String == "Loyalty Card Detail")
        
        event = MixpanelTrackableEvent.lcdViewed(brandName: "Doom", route: .lcd)
        XCTAssertTrue(event.data!["Brand name"] as! String == "Doom")
        XCTAssertTrue(event.data!["Route"] as! String == "Loyalty Card Detail")
        
        event = MixpanelTrackableEvent.loyaltyCardManuallyReordered(brandName: "Doom", originalIndex: 0, destinationIndex: 1)
        XCTAssertTrue(event.data!["Brand name"] as! String == "Doom")
        XCTAssertTrue(event.data!["Original index"] as! Int == 0)
        XCTAssertTrue(event.data!["Destination index"] as! Int == 1)
        
        event = MixpanelTrackableEvent.localPointsCollectionSuccess(brandName: "Doom")
        XCTAssertTrue(event.data!["Brand name"] as! String == "Doom")
        
        event = MixpanelTrackableEvent.localPointsCollectionFailure(brandName: "Doom", reason: "error", underlyingError: "error")
        XCTAssertTrue(event.data!["Brand name"] as! String == "Doom")
        XCTAssertTrue(event.data!["Reason"] as! String == "error")
        XCTAssertTrue(event.data!["Underlying error"] as! String == "error")
        
        event = MixpanelTrackableEvent.onboardingStart(route: .magicLink)
        XCTAssertTrue(event.data!["Route"] as! String == "Magic link")
        
        event = MixpanelTrackableEvent.onboardingComplete(route: .magicLink)
        XCTAssertTrue(event.data!["Route"] as! String == "Magic link")
        
        event = MixpanelTrackableEvent.viewBarcode(brandName: "Doom", route: .lcd)
        XCTAssertTrue(event.data!["Brand name"] as! String == "Doom")
        XCTAssertTrue(event.data!["Route"] as! String == "Loyalty Card Detail")
        
        event = MixpanelTrackableEvent.barcodeScreenIssueReported(brandName: "Doom", reason: .barcodeWontScan)
        XCTAssertTrue(event.data!["Reason"] as! String == "Barcode won't scan")
        XCTAssertTrue(event.data!["Brand name"] as! String == "Doom")
        
        event = MixpanelTrackableEvent.toLocations(brandName: "Doom")
        XCTAssertTrue(event.data!["Brand"] as! String == "Doom")
        
        event = MixpanelTrackableEvent.toAppleMaps(brandName: "Doom")
        XCTAssertTrue(event.data!["Brand"] as! String == "Doom")
        
        event = MixpanelTrackableEvent.toGoogleMaps(brandName: "Doom")
        XCTAssertTrue(event.data!["Brand"] as! String == "Doom")
    }
    
    func test_mixpanelUserProperty_correctStrings() throws {
        var event = MixpanelUserProperty.appleWatchInstalled(true)
        XCTAssertTrue(event.identifier == "Apple Watch Installed")
        
        event = MixpanelUserProperty.totalLoyaltyCards(1)
        XCTAssertTrue(event.identifier == "Total number of loyalty cards")
        
        event = MixpanelUserProperty.totalPLLCards(1)
        XCTAssertTrue(event.identifier == "Total number of PLL cards")
        
        event = MixpanelUserProperty.activePLLCards(1)
        XCTAssertTrue(event.identifier == "Total number of active PLL cards")
        
        event = MixpanelUserProperty.localPointsCollectionCards
        XCTAssertTrue(event.identifier == "Local points collection cards")
        
        event = MixpanelUserProperty.widget(true)
        XCTAssertTrue(event.identifier == "Has widget installed")
        
        event = MixpanelUserProperty.loyaltyCards
        XCTAssertTrue(event.identifier == "Loyalty cards")
        
        event = MixpanelUserProperty.lastEngaged(1)
        XCTAssertTrue(event.identifier == "Last engaged")
        
        event = MixpanelUserProperty.lastEngaged(1)
        XCTAssertTrue(event.identifier == "Last engaged")
        
        event = MixpanelUserProperty.loyaltyCardsSortOrder("Custom")
        XCTAssertTrue(event.identifier == "Wallet Sort Setting")
        
        event = MixpanelUserProperty.showBarcodeAlways(true)
        XCTAssertTrue(event.identifier == "Show barcode always")
    }
    
    func test_mixpanelUserProperty_correctData() throws {
        var event = MixpanelUserProperty.appleWatchInstalled(true)
        XCTAssertTrue(event.data["Apple Watch Installed"] as! Bool == true)
        
        event = MixpanelUserProperty.loyaltyCardsSortOrder("Custom")
        XCTAssertTrue(event.data["Wallet Sort Setting"] as! String == "Custom")
        
        event = MixpanelUserProperty.showBarcodeAlways(true)
        XCTAssertTrue(event.data["Show barcode always"] as! Bool == true)
        
    }
}
