//
//  CustomAnnotation.swift
//  binkapp
//
//  Created by Sean Williams on 07/11/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

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
