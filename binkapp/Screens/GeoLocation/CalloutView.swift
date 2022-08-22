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
    let feature: Feature
    let coordinate: CLLocationCoordinate2D
    let image = UIImage(named: Asset.locationArrow.name)
    var openingHoursColor: UIColor?
    
    init(coordinate: CLLocationCoordinate2D, feature: Feature) {
        self.coordinate = coordinate
        self.feature = feature
        super.init()
    }
    
    var location: String {
        return (feature.properties.locationName ?? "") + " - " + (feature.properties.city ?? "")
    }
    
    var openHours: String {
        return configureOpenHours(openHours: feature.properties.openHours)
    }
    
    private func configureOpenHours(openHours: String?) -> String {
        guard let data = openHours?.data(using: .utf8) else { return "" }
        do {
            let openHours = try JSONDecoder().decode(OpenHours.self, from: data)
            if let hoursDict = openHours.dictionary as? [String: [[String]]] {
                let today = Date.today().string
                let dayHours = hoursDict[today] ?? [[]]
                let openingHoursArray = Array(dayHours.joined())
                
                guard !openingHoursArray.isEmpty else {
                    // TODO: - Get next days opening hour
                    return "Closed - Opens at ..."
                }
                
                var openingHourWithMinutes = openingHoursArray[0]
                let closingHourWithMinutes = openingHoursArray[1]
                guard let openingHour = Int(openingHourWithMinutes.dropLast(3)), let closingHour = Int(closingHourWithMinutes.dropLast(3)) else { return "" }

                if openingHourWithMinutes.count == 4 {
                    openingHourWithMinutes.insert("0", at: openingHourWithMinutes.startIndex)
                }
                
                // Check if current time is before closing time
                var currentHour = Calendar.current.component(.hour, from: Date())
//                let currentMinute = Calendar.current.component(.minute, from: Date())
                currentHour = 23
                if currentHour == (closingHour - 1) {
                    openingHoursColor = .systemOrange
                    return "Closing Soon - Closes at \(closingHourWithMinutes)"
                } else if currentHour >= openingHour && currentHour < closingHour {
                    openingHoursColor = .systemGreen
                    return "Open - Closes at \(closingHourWithMinutes)"
                } else {
                    openingHoursColor = .systemRed
                    return "Closed - Opens at \(openingHourWithMinutes)" // WRONG - get tomorrows opening hours <<<<<<<<<<<<<<<<<<<<<<
                }
            }
        } catch {
            print(String(describing: error))
        }
        
        return ""
    }
}

class CalloutView: UIView {
    private lazy var textStack: UIStackView = {
        let stackview = UIStackView(arrangedSubviews: [titleLabel, openingHoursLabel, subtitleLabel])
        stackview.translatesAutoresizingMaskIntoConstraints = false
        stackview.axis = .vertical
        stackview.distribution = .fill
        addSubview(stackview)
        return stackview
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .alertText
        label.text = annotation.location
        label.textColor = Current.themeManager.color(for: .text)
        return label
    }()
    
    private lazy var openingHoursLabel: UILabel = {
        let label = UILabel()
        label.font = .alertText
        label.text = annotation.openHours
        label.textColor = annotation.openingHoursColor
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
            imageView.widthAnchor.constraint(equalToConstant: 40),
            textStack.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: (LayoutHelper.GeoLocationCallout.padding * 2)),
            textStack.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            textStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 15),
            textStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 15)
        ])
    }
}
