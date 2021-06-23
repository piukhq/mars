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
        WidgetContent(date: Date(), hasCurrentUser: true)
    }

    func getSnapshot(in context: Context, completion: @escaping (WidgetContent) -> Void) {
        let entry = WidgetContent(date: Date(), hasCurrentUser: true)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        let hasCurrentUser = UserDefaults(suiteName: "group.com.bink.wallet")?.bool(forKey: "hasCurrentUser") ?? false
        var entries: [WidgetContent] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .second, value: hourOffset, to: currentDate) ?? Date()
            let entry = WidgetContent(date: entryDate, hasCurrentUser: hasCurrentUser)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct WidgetContent: TimelineEntry {
    let date: Date
    let hasCurrentUser: Bool
    let walletCards: [MembershipCard] = []
}

struct MembershipCard {
    let image: UIImage
    let backGroundColor: UIColor
    let cardNumber: String
}

struct QuickLaunchEntryView: View {
    let model: QuickLaunchProvider.Entry
    var twoColumnGrid = [GridItem(.flexible()), GridItem(.flexible())]
    var symbols = ["keyboard", "hifispeaker.fill", "printer.fill", "tv.fill"]
    
    var body: some View {
        if model.hasCurrentUser {
            LazyVGrid(columns: twoColumnGrid, spacing: 33) {
                ForEach(symbols, id: \.self) { _ in
                    HStack(alignment: .center, spacing: 42.0) {
                        Image("hn")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(.leading, 3.0)
                            .frame(width: 36.0, height: 36.0)
                        Text("••5776")
                            .font(.footnote)
                            .fontWeight(.semibold)
                            .foregroundColor(Color.white)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 14.0)
                            .frame(minWidth: 153, maxWidth: .infinity, minHeight: 65)
                            .foregroundColor(.black)
                    )
                }
            }
            .frame(height: 160)
            .padding(.all, 9.0)
            .background(Color("WidgetBackground"))
        } else {
            UnauthenticatedSwiftUIView()
        }
    }
}

@main
struct BinkWidget: Widget {
    let kind: String = "com.bink.QuickLaunch"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: QuickLaunchProvider()) { entry in
            QuickLaunchEntryView(model: entry)
        }
        .configurationDisplayName("Bink quick launch")
        .description("Quickly access your favourite loyalty cards.")
        .supportedFamilies([.systemMedium])
    }
}

struct BinkWidget_Previews: PreviewProvider {
    static var previews: some View {
        QuickLaunchEntryView(model: WidgetContent(date: Date(), hasCurrentUser: true))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
            .preferredColorScheme(.light)
    }
}
