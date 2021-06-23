//
//  BinkWidget.swift
//  BinkWidget
//
//  Created by Sean Williams on 22/06/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import WidgetKit
import SwiftUI

let previewWalletCards: [MembershipCard] = [
    MembershipCard(id: "1", image: UIImage(named: "hn") ?? UIImage(), backgroundColor: .black, isLight: false, cardNumber: "2678876526788762"),
    MembershipCard(id: "2", image: UIImage(named: "wasabi") ?? UIImage(), backgroundColor: .green, isLight: true, cardNumber: "26788765267898202"),
    MembershipCard(id: "3", image: UIImage(named: "iceland") ?? UIImage(), backgroundColor: .white, isLight: true, cardNumber: "2678876526789234")
]

struct QuickLaunchProvider: TimelineProvider {
    func placeholder(in context: Context) -> WidgetContent {
        WidgetContent(date: Date(), hasCurrentUser: true, walletCards: previewWalletCards)
    }

    func getSnapshot(in context: Context, completion: @escaping (WidgetContent) -> Void) {
        let entry = WidgetContent(date: Date(), hasCurrentUser: true, walletCards: previewWalletCards)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        let hasCurrentUser = UserDefaults(suiteName: "group.com.bink.wallet")?.bool(forKey: "hasCurrentUser") ?? false
        var entries: [WidgetContent] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .second, value: hourOffset, to: currentDate) ?? Date()
            let entry = WidgetContent(date: entryDate, hasCurrentUser: hasCurrentUser, walletCards: previewWalletCards)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct WidgetContent: TimelineEntry {
    let date: Date
    let hasCurrentUser: Bool
    let walletCards: [MembershipCard]
}

struct MembershipCard: Hashable {
    let id: String
    let image: UIImage
    let backgroundColor: Color
    let isLight: Bool
    let cardNumber: String
}

struct QuickLaunchEntryView: View {
    let model: QuickLaunchProvider.Entry
    var twoColumnGrid = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        if model.hasCurrentUser {
            LazyVGrid(columns: twoColumnGrid, spacing: 33) {
                ForEach(model.walletCards, id: \.self) { membershipCard in
                    HStack(alignment: .center, spacing: 42.0) {
                        Image(uiImage: membershipCard.image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(.leading, 3.0)
                            .frame(width: 36.0, height: 36.0)
                        Text("••\(String(membershipCard.cardNumber.suffix(4)))")
                            .font(.system(size: 10, weight: .semibold, design: .rounded))
                            .fontWeight(.semibold)
                            .foregroundColor(membershipCard.isLight ? .black : .white)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 14.0)
                            .frame(minWidth: 153, maxWidth: .infinity, minHeight: 64)
                            .foregroundColor(membershipCard.backgroundColor)
                    )
                }
                
                if model.walletCards.count < 4 {
                    Image(systemName: "plus")
                        .foregroundColor(.white)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .frame(minWidth: 153, maxWidth: .infinity, minHeight: 64)
                                .foregroundColor(.clear)
                                .border(Color.gray, width: 1).cornerRadius(14)
                        )
                }
            }
            .frame(height: 160.0)
            .padding(.all, 11.0)
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
        QuickLaunchEntryView(model: WidgetContent(date: Date(), hasCurrentUser: true, walletCards: previewWalletCards))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
            .preferredColorScheme(.light)
    }
}
