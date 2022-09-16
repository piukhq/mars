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
    var selectedAnnotation: CustomAnnotation?
    
    init(companyName: String) {
        self.companyName = companyName
    }
    
    var annotations: [CustomAnnotation] {
        features.compactMap { feature in
            guard let lat = feature.geometry.coordinates[safe: 1], let lon = feature.geometry.coordinates[safe: 0] else { return nil }
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            return CustomAnnotation(coordinate: coordinate, feature: feature)
        }
    }
    
    var features: [Feature] {
        return geoLocationDataModel?.features ?? []
    }
    
    var title: String {
        return companyName + " " + L10n.locations
    }
    
    private func getGeoLocationData() -> Data? {
        let geoLocationFileName = companyName.replacingOccurrences(of: " ", with: "-").lowercased()
        if let cachedGeoData = Cache.geoLocationsDataCache.object(forKey: "\(geoLocationFileName).geojson".toNSString()) {
            return cachedGeoData as Data
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
    
    func openAppleMaps() {
        if let annotation = selectedAnnotation {
            let latitude = annotation.coordinate.latitude
            let longitude = annotation.coordinate.longitude
            let regionDistance: CLLocationDistance = 10000
            let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
            let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
            let options = [
                MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
                MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
            ]
            let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: options)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = annotation.location
            if mapItem.openInMaps(launchOptions: nil) {
                MixpanelUtility.track(.toAppleMaps(brandName: companyName))
            }
        }
    }
}
