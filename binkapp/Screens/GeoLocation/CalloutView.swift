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
        let dayoffset = 0
        
        do {
            let weeklyOpeningHours = try JSONDecoder().decode(OpenHours.self, from: data)
            guard let todaysOpeningHours = weeklyOpeningHours.openingHours(for: Date.today() + dayoffset) else {
                /// No opening hours for today
                openingHoursColor = .systemRed
                if let nextOpeningTimes = weeklyOpeningHours.openingTimesForNextOpenDay(from: Date.today() + dayoffset) {
                    let nextOpenDayIsTomorrow = nextOpeningTimes.day == Date.tomorrow() + dayoffset
                    let dayString = nextOpenDayIsTomorrow ? "" : " on \(nextOpeningTimes.dayString)"
                    return "Closed - Opens at \(nextOpeningTimes.opening)\(dayString)"
                }
                return ""
            }
            
            guard let openingHour = Int(todaysOpeningHours.opening.dropLast(3)), let closingHour = Int(todaysOpeningHours.closing.dropLast(3)) else { return "" }
            guard var nextOpeningTimes = weeklyOpeningHours.openingTimesForNextOpenDay(from: Date.tomorrow() + dayoffset) else { return "" }

            if nextOpeningTimes.opening.count == 4 {
                nextOpeningTimes.opening.insert("0", at: nextOpeningTimes.opening.startIndex)
            }
            
            var currentHour = Calendar.current.component(.hour, from: Date())
//            currentHour = 23
            if currentHour == (closingHour - 1) {
                openingHoursColor = .systemOrange
                return "Closing Soon - Closes at \(todaysOpeningHours.closing)"
            } else if currentHour >= openingHour && currentHour < closingHour {
                openingHoursColor = .systemGreen
                return "Open - Closes at \(todaysOpeningHours.closing)"
            } else if currentHour < openingHour {
                openingHoursColor = .systemRed
                return "Closed - Opens at \(todaysOpeningHours.opening)"
            } else {
                openingHoursColor = .systemRed
                let nextOpenDayIsTomorrow = nextOpeningTimes.day == Date.tomorrow() + dayoffset
                let dayString = nextOpenDayIsTomorrow ? "" : " on \(nextOpeningTimes.dayString)"
                let str = "Closed - Opens at \(nextOpeningTimes.opening)\(dayString)"
                return str
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
        label.font = .calloutViewTitle
        label.text = annotation.location
        label.textColor = Current.themeManager.color(for: .text)
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
            imageView.widthAnchor.constraint(equalToConstant: 40),
            textStack.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: (LayoutHelper.GeoLocationCallout.padding * 2)),
            textStack.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            textStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 15),
            textStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 15)
        ])
    }
}
