//
//  CalloutView.swift
//  binkapp
//
//  Created by Ricardo Silva on 07/07/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import UIKit

class CalloutView: UIView {
    lazy var textStack: UIStackView = {
        let stackview = UIStackView(arrangedSubviews: [titleLabel, openingHoursLabel, subtitleLabel])
        stackview.translatesAutoresizingMaskIntoConstraints = false
        stackview.axis = .vertical
        stackview.distribution = .fill
        addSubview(stackview)
        return stackview
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .calloutViewTitle
        label.text = annotation.location
        label.textColor = Current.themeManager.color(for: .text)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()
    
    private lazy var openingHoursLabel: UILabel = {
        let label = UILabel()
        label.font = .calloutViewOpeningHours
        label.text = annotation.openHours
        label.textColor = annotation.openingHoursColor
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .calloutViewSubtitle
        label.textColor = Current.themeManager.color(for: .text)
        label.text = L10n.pressForDirections
        return label
    }()
    
    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.image = annotation.image
        view.contentMode = .scaleAspectFit
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let annotation: CustomAnnotation
    
    init(annotation: CustomAnnotation) {
        self.annotation = annotation
        super.init(frame: .zero)
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureLayout() {
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: LayoutHelper.GeoLocationCallout.calloutHeight).isActive = true
        widthAnchor.constraint(equalToConstant: LayoutHelper.GeoLocationCallout.calloutWidth).isActive = true
        addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.leftAnchor.constraint(equalTo: leftAnchor, constant: LayoutHelper.GeoLocationCallout.padding),
            imageView.topAnchor.constraint(equalTo: topAnchor, constant: LayoutHelper.GeoLocationCallout.padding),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -LayoutHelper.GeoLocationCallout.padding),
            imageView.widthAnchor.constraint(equalToConstant: LayoutHelper.GeoLocationCallout.imageWidth),
            textStack.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: (LayoutHelper.GeoLocationCallout.padding * 2)),
            textStack.topAnchor.constraint(equalTo: topAnchor),
            textStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
            textStack.rightAnchor.constraint(equalTo: rightAnchor, constant: -LayoutHelper.GeoLocationCallout.padding)
        ])
    }
}
