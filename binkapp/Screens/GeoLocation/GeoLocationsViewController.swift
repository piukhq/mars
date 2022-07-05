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
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setMapConstraints()
        viewModel.parseGeoJson()
        determineCurrentLocation()
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
}

extension GeoLocationsViewController: MKMapViewDelegate {
}

extension GeoLocationsViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation: CLLocation = locations[0] as CLLocation

        let center = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))

        mapView.setRegion(region, animated: true)
        
        let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2DMake(userLocation.coordinate.latitude, userLocation.coordinate.longitude)
            annotation.title = currentLocationStr
            mapView.addAnnotation(annotation)
        
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error - locationManager: \(error.localizedDescription)")
    }
}
