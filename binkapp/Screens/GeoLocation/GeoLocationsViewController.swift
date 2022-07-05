//
//  GeoLocationsViewController.swift
//  binkapp
//
//  Created by Ricardo Silva on 04/07/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class GeoLocationsViewController: UIViewController {
    private let viewModel = GeoLocationViewModel()
    var locationManager: CLLocationManager!
    var currentLocationStr = "Current location"
    
    private lazy var mapView: MKMapView = {
        let map = MKMapView()
        map.overrideUserInterfaceStyle = .dark
        return map
    }()
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setMapConstraints() {
        view.addSubview(mapView)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        mapView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        mapView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        mapView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        
        mapView.delegate = self
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        mapView.showsUserLocation = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setMapConstraints()
        viewModel.parseGeoJson()
        determineCurrentLocation()
        addAnnotations()
    }
    
    func determineCurrentLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()

        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
    
    func addAnnotations() {
        for feature in viewModel.geoLocationDataModel?.features ?? [] {
            print(feature)
            let coordinates = CLLocationCoordinate2D(latitude: feature.geometry.coordinates[1], longitude: feature.geometry.coordinates[0])
            let pin = CustomAnnotation(
            title: feature.properties.location_name,
            location: feature.properties.city,
            coordinate: coordinates)
            mapView.addAnnotation(pin)
        }
    }
}

extension GeoLocationsViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? CustomAnnotation else {
            return nil
        }
        
        let identifier = "customAnnotation"
        var view: MKMarkerAnnotationView
        
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        return view
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        print("tapped")
    }
}

extension GeoLocationsViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation: CLLocation = locations[0] as CLLocation

        let center = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))

        mapView.setRegion(region, animated: true)
        
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error - locationManager: \(error.localizedDescription)")
    }
}

class CustomAnnotation: NSObject, MKAnnotation {
    let title: String?
    let location: String?
    let coordinate: CLLocationCoordinate2D
    
    init(title: String?, location: String?, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.location = location
        self.coordinate = coordinate
        
        super.init()
    }
    
    var subtitle: String? {
        return location
    }
}
