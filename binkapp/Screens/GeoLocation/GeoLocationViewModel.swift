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
            let annotation = CustomAnnotation(
                location: (feature.properties.locationName ?? "") + " - " + (feature.properties.city ?? ""),
                coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                image: UIImage(named: Asset.locationArrow.name))
            return annotation
        }
    }
    
    var features: [Feature] {
        return geoLocationDataModel?.features ?? []
    }
    
    var title: String {
        return companyName + " " + L10n.locations
    }
    
    private func getGeoLocationData() -> Data? {
        // RS - loading from the bundle for now. In the future this will eventually coming down through firebase and will be different per company
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
