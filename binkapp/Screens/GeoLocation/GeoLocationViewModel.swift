//
//  GeoLocationViewModel.swift
//  binkapp
//
//  Created by Ricardo Silva on 05/07/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import Foundation
import MapKit

class GeoLocationViewModel: ObservableObject {
    private var geoLocationDataModel: GeoModel?
    private var companyName: String
    
    init(companyName: String) {
        self.companyName = companyName
    }
    
    var annotations: [CustomAnnotation] {
        features.compactMap { feature in
            let coordinates = CLLocationCoordinate2D(latitude: feature.geometry.coordinates[1], longitude: feature.geometry.coordinates[0])
            let annotation = CustomAnnotation(
                location: (feature.properties.location_name ?? "") + " - " + (feature.properties.city ?? ""),
                coordinate: coordinates,
                image: UIImage(named: "location_arrow"))
            return annotation
        }
    }
    
    var features: [Feature] {
        return geoLocationDataModel?.features ?? []
    }
    
    var title : String {
        return companyName + " " + "Locations"
    }
    
    func trackEvent() {
        MixpanelUtility.track(.toAppleMaps(brandName: companyName, description: L10n.launchedAppleMaps))
    }
    
    private func getGeoLocationData() -> Data? {
        if let filePath = Bundle.main.path(forResource: "tesco-locations", ofType: "geojson") {
            do {
                let data = try String(contentsOfFile: filePath).data(using: .utf8)
                return data
            } catch {
                print("File error")
            }
        }
        
        return nil
    }
    
    func parseGeoJson() {
        if let jsonData = getGeoLocationData() {
            do {
                geoLocationDataModel = try JSONDecoder().decode(GeoModel.self, from: jsonData)
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
}
