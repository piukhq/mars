//
//  PLR_Widget.swift
//  PLR Widget
//
//  Created by Nick Farrant on 14/04/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), earnTarget: 7, earnValue: 3)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let entry = SimpleEntry(date: Date(), earnTarget: 7, earnValue: 3)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)
            let entry = SimpleEntry(date: entryDate ?? Date(), earnTarget: 7, earnValue: 3)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

// This entry should contain all the data we need to display on the widget
struct SimpleEntry: TimelineEntry {
    let date: Date
    let earnTarget: Int
    let earnValue: Int
}

struct PLR_WidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        VStack {
            Text("\(entry.earnValue) of \(entry.earnTarget) stamps")
        }
    }
}

@main
struct PLR_Widget: Widget {
    let kind: String = "PLR_Widget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            PLR_WidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Vouchers widget")
        .description("A widget that displays your first available active or in-progress voucher.")
        .supportedFamilies([.systemMedium])
    }
}

struct PLR_Widget_Previews: PreviewProvider {
    static var previews: some View {
        PLR_WidgetEntryView(entry: SimpleEntry(date: Date(), earnTarget: 7, earnValue: 3))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
