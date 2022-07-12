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
    private let viewModel: GeoLocationViewModel
    private var locationManager: CLLocationManager!
    
    init(viewModel: GeoLocationViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    private lazy var mapView: MKMapView = {
        let map = MKMapView()
        map.isZoomEnabled = true
        map.isScrollEnabled = true
        map.isUserInteractionEnabled = true
        map.showsUserLocation = true
        map.delegate = self
        map.tintColor = .systemBlue
        map.translatesAutoresizingMaskIntoConstraints = false
        return map
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setMapConstraints() {
        view.addSubview(mapView)
        mapView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        mapView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        mapView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        mapView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = viewModel.title
        
        setMapConstraints()
        viewModel.parseGeoJson()
        addAnnotations()
        determineCurrentLocation()
    }
    
    private func determineCurrentLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()

        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
    
    private func addAnnotations() {
        mapView.addAnnotations(viewModel.annotations)
    }
    
    @objc func tapOnCallout(sender: UIButton) {
        viewModel.openAppleMaps()
    }
}

extension GeoLocationsViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? CustomAnnotation else { return nil }

        let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        annotationView?.canShowCallout = true
        annotationView?.detailCalloutAccessoryView = CalloutView(annotation: annotation)
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        viewModel.selectedAnnotation = view.annotation as? CustomAnnotation
        for gesture in view.gestureRecognizers ?? [] {
            view.removeGestureRecognizer(gesture)
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapOnCallout(sender:)))
        view.addGestureRecognizer(tapGesture)
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        viewModel.selectedAnnotation = nil
        for gesture in view.gestureRecognizers ?? [] {
            view.removeGestureRecognizer(gesture)
        }
    }
}

extension GeoLocationsViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let userLocation = locations.last {
            let center = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
            
            mapView.setRegion(region, animated: true)
            
            locationManager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error - locationManager: \(error.localizedDescription)")
    }
}
