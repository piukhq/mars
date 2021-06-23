//
//  BinkWidget.swift
//  BinkWidget
//
//  Created by Sean Williams on 22/06/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import WidgetKit
import SwiftUI

struct QuickLaunchProvider: TimelineProvider {
    func placeholder(in context: Context) -> WidgetContent {
        WidgetContent(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (WidgetContent) -> Void) {
        let entry = WidgetContent(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        var entries: [WidgetContent] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate) ?? Date()
            let entry = WidgetContent(date: entryDate)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct WidgetContent: TimelineEntry {
    let date: Date
}

struct QuickLaunchEntryView: View {
    var entry: QuickLaunchProvider.Entry
    
    var body: some View {
        let hasCurrentUser = UserDefaults(suiteName: "group.com.bink.wallet")?.bool(forKey: "hasCurrentUser") ?? false
        
        // if signed in show wallet cards
        if hasCurrentUser {
            Text("Has user")
        } else {
            HStack(alignment: .center, spacing: 0) {
                Image("bink-logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(.all, 13.0)
                Text("Tap to sign in to Bink")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.trailing)
                    .padding(.horizontal, 16.0)
            }
            .padding(.vertical, 11.0)
            .background(Color("WidgetBackground"))
        }        
//        Text(entry.date, style: .time)
    }
}

@main
struct BinkWidget: Widget {
    let kind: String = "com.bink.QuickLaunch"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: QuickLaunchProvider()) { entry in
            QuickLaunchEntryView(entry: entry)
        }
        .configurationDisplayName("Bink quick launch")
        .description("Quickly access your favourite loyalty cards.")
        .supportedFamilies([.systemMedium])
    }
}

struct BinkWidget_Previews: PreviewProvider {
    static var previews: some View {
        QuickLaunchEntryView(entry: WidgetContent(date: Date()))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
            .preferredColorScheme(.dark)
    }
}
