//
//  CalloutViewTests.swift
//  binkappTests
//
//  Created by Sean Williams on 04/11/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import XCTest
import MapKit
@testable import binkapp

final class CalloutViewTests: XCTestCase {
    static var sut: CalloutView!
    
    override class func setUp() {
        super.setUp()
        
        let properties = Properties(locationName: nil, latitude: nil, longitude: nil, streetAddress: nil, city: nil, region: nil, postalCode: nil, phoneNumber: nil, openHours: nil)
        let geometry = Geometry(type: "", coordinates: [])
        
        let feature = Feature(type: "", properties: properties, geometry: geometry)
        let coordinate = CLLocationCoordinate2D()
        
        sut = CalloutView(annotation: CustomAnnotation(coordinate: coordinate, feature: feature))
    }
    
    func test_textStackGetter_successfullyReturnsStackView() {
        
    }
    
}
