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
        return configureOpeningHours(feature.properties.openHours)
    }
    
    private func configureOpeningHours(_ openHours: String?) -> String {
        guard let data = openHours?.data(using: .utf8) else { return "" }
        
        do {
            let weeklyOpeningHours = try JSONDecoder().decode(OpenHours.self, from: data)
            guard let todaysOpeningTimes = weeklyOpeningHours.openingTimes(for: Current.dateManager.today()) else {
                return configureNextOpenTimes(openHours: weeklyOpeningHours, from: Current.dateManager.today())
            }
            guard let openingHour = Int(todaysOpeningTimes.opening.dropLast(3)), let closingHour = Int(todaysOpeningTimes.closing.dropLast(3)) else { return "" }
            let currentHour = Current.dateManager.currentHour
            
            if currentHour == (closingHour - 1) {
                openingHoursColor = .systemOrange
                return "Closing Soon - Closes at \(todaysOpeningTimes.closing)"
            } else if currentHour >= openingHour && currentHour < closingHour {
                openingHoursColor = .systemGreen
                return "Open - Closes at \(todaysOpeningTimes.closing)"
            } else if currentHour < openingHour {
                openingHoursColor = .systemRed
                return "Closed - Opens at \(todaysOpeningTimes.opening)"
            } else {
                return configureNextOpenTimes(openHours: weeklyOpeningHours, from: Current.dateManager.tomorrow())
            }
        } catch {
            print(String(describing: error))
        }
        
        return ""
    }
    
    private func configureNextOpenTimes(openHours: OpenHours, from day: Int) -> String {
        openingHoursColor = .systemRed
        if var nextOpeningTimes = openHours.openingTimesForNextOpenDay(from: day) {
            if nextOpeningTimes.opening.count == 4 { /// If the opening time string has 4 characters, we know it must be missing the first zero (e.g. 7:24)
                nextOpeningTimes.opening.insert("0", at: nextOpeningTimes.opening.startIndex)
            }
            let nextOpenDayIsTomorrow = nextOpeningTimes.day == Current.dateManager.tomorrow()
            let dayString = nextOpenDayIsTomorrow ? "" : " on \(nextOpeningTimes.dayString)"
            return "Closed - Opens at \(nextOpeningTimes.opening)\(dayString)"
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
