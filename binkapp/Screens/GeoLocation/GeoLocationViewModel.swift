//
//  GeoLocationViewModel.swift
//  binkapp
//
//  Created by Ricardo Silva on 05/07/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import Foundation
import MapKit

class GeoLocationViewModel {
    var geoLocationDataModel: GeoModel?
    var coordinates: [CLLocation] = []
    
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
                for feature in geoLocationDataModel?.features ?? [] {
                    let location = CLLocation(latitude: feature.geometry.coordinates[1], longitude: feature.geometry.coordinates[0])
                    coordinates.append(location)
                }
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
}
