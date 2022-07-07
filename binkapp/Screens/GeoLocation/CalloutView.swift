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
    private let titleLabel = UILabel(frame: .zero)
    private let subtitleLabel = UILabel(frame: .zero)
    private let imageView = UIImageView(frame: .zero)
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
        heightAnchor.constraint(equalToConstant: 80).isActive = true
        widthAnchor.constraint(equalToConstant: 340).isActive = true
        
        setupTitle()
        setupSubtitle()
        setupImageView()
    }
    
    private func setupTitle() {
        titleLabel.font = .alertText
        titleLabel.text = annotation.location
        titleLabel.textColor = Current.themeManager.color(for: .text)
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 84).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
    
    private func setupSubtitle() {
        subtitleLabel.font = .navbarHeaderLine2
        subtitleLabel.textColor = Current.themeManager.color(for: .text)
        subtitleLabel.text = L10n.pressForDirections
        addSubview(subtitleLabel)
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8).isActive = true
        subtitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 84).isActive = true
        subtitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
    
    private func setupImageView() {
        imageView.image = annotation.image
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 18).isActive = true
        imageView.topAnchor.constraint(equalTo: topAnchor, constant: 18).isActive = true
        imageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -18).isActive = true
        imageView.rightAnchor.constraint(equalTo: titleLabel.leftAnchor, constant: -18).isActive = true
    }
}
