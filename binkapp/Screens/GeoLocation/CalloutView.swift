//
//  CalloutView.swift
//  binkapp
//
//  Created by Ricardo Silva on 07/07/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class CustomAnnotation: NSObject, MKAnnotation {
    let location: String?
    let coordinate: CLLocationCoordinate2D
    let image: UIImage?
    
    init(location: String?, coordinate: CLLocationCoordinate2D, image: UIImage?) {
        self.location = location
        self.coordinate = coordinate
        self.image = image
        
        super.init()
    }
}

class CalloutView: UIView {
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .alertText
        label.text = annotation.location
        label.textColor = Current.themeManager.color(for: .text)
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .navbarHeaderLine2
        label.textColor = Current.themeManager.color(for: .text)
        label.text = L10n.pressForDirections
        return label
    }()
    
    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.image = annotation.image
        view.contentMode = .scaleAspectFit
        view.clipsToBounds = true
        return view
    }()
    
    private let annotation: CustomAnnotation
    
    init(annotation: CustomAnnotation) {
        self.annotation = annotation
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: LayoutHelper.GeoLocationCallout.calloutHeight).isActive = true
        widthAnchor.constraint(equalToConstant: LayoutHelper.GeoLocationCallout.calloutwidth).isActive = true
        
        setupTitle()
        setupSubtitle()
        setupImageView()
    }
    
    private func setupTitle() {
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: LayoutHelper.GeoLocationCallout.titleLabelTopOffset).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: LayoutHelper.GeoLocationCallout.titleLabelLeadingOffset).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
    
    private func setupSubtitle() {
        addSubview(subtitleLabel)
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: LayoutHelper.GeoLocationCallout.subTitleLabelTopOffset).isActive = true
        subtitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: LayoutHelper.GeoLocationCallout.titleLabelLeadingOffset).isActive = true
        subtitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
    
    private func setupImageView() {
        addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.leftAnchor.constraint(equalTo: leftAnchor, constant: LayoutHelper.GeoLocationCallout.imageViewOffset).isActive = true
        imageView.topAnchor.constraint(equalTo: topAnchor, constant: LayoutHelper.GeoLocationCallout.imageViewOffset).isActive = true
        imageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -LayoutHelper.GeoLocationCallout.imageViewOffset).isActive = true
        imageView.rightAnchor.constraint(equalTo: titleLabel.leftAnchor, constant: -LayoutHelper.GeoLocationCallout.imageViewOffset).isActive = true
    }
}
