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
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setMapConstraints()
        
        viewModel.parseGeoJson()
    }
}

extension GeoLocationsViewController: MKMapViewDelegate {
     
}
