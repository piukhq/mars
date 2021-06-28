//
//  BinkWidget.swift
//  BinkWidget
//
//  Created by Sean Williams on 22/06/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import WidgetKit
import SwiftUI

let previewWalletCards: [MembershipCardWidget] = [
    MembershipCardWidget(id: "1", imageData: nil, backgroundColor: "", isLight: false, cardNumber: "2678876526788762"),
    MembershipCardWidget(id: "2", imageData: nil, backgroundColor: "", isLight: true, cardNumber: "26788765267898202"),
    MembershipCardWidget(id: "3", imageData: nil, backgroundColor: "", isLight: true, cardNumber: "2678876526789234")
]

struct QuickLaunchProvider: TimelineProvider {
    func placeholder(in context: Context) -> WidgetContent {
        WidgetContent(hasCurrentUser: true, walletCards: previewWalletCards)
    }

    func getSnapshot(in context: Context, completion: @escaping (WidgetContent) -> Void) {
        let entry = WidgetContent(hasCurrentUser: true, walletCards: previewWalletCards)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
//        let hasCurrentUser = UserDefaults(suiteName: "group.com.bink.wallet")?.bool(forKey: "hasCurrentUser") ?? false
        let entries = readContents()
        
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
//        let currentDate = Date()
//        for hourOffset in 0 ..< 5 {
//            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate) ?? Date()
//            var entry = WidgetContent(hasCurrentUser: true, walletCards: previewWalletCards)
//            entry.date = entryDate
//            entries.append(entry)
//        }
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
    
    func readContents() -> [WidgetContent] {
        var contents: [WidgetContent] = []
        let archiveURL = FileManager.sharedContainerURL().appendingPathComponent("contents.json")
        print(">>> \(archiveURL)")

        let decoder = JSONDecoder()
        if let codeData = try? Data(contentsOf: archiveURL) {
            do {
                let widgetContent = try decoder.decode(WidgetContent.self, from: codeData)
                contents.append(widgetContent)
            } catch {
                print("Error: can't decode contents")
            }
        }
        return contents
    }
}

struct QuickLaunchEntryView: View {
    let model: QuickLaunchProvider.Entry
    var twoColumnGrid = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        if model.hasCurrentUser {
            LazyVGrid(columns: twoColumnGrid, spacing: 33) {
                ForEach(model.walletCards, id: \.self) { membershipCard in
                    HStack(alignment: .center, spacing: 42.0) {
                        if let imageData = membershipCard.imageData {
                            if let uiImage = UIImage(data: imageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .padding(.leading, 3.0)
                                    .frame(width: 36.0, height: 36.0)
                            }
                        }

                        Text("••\(String(membershipCard.cardNumber.suffix(4)))")
                            .font(.system(size: 10, weight: .semibold, design: .rounded))
                            .fontWeight(.semibold)
                            .foregroundColor(membershipCard.isLight ? .black : .white)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 14.0)
                            .frame(minWidth: 153, maxWidth: .infinity, minHeight: 64)
                            .foregroundColor(Color(UIColor(hexString: membershipCard.backgroundColor)))
                    )
                }
                
                if model.walletCards.count < 4 {
                    Image(systemName: "plus")
                        .foregroundColor(.white)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .frame(minWidth: 153, maxWidth: .infinity, minHeight: 64)
                                .foregroundColor(.clear)
                                .border(Color.gray, width: 1)
                                .cornerRadius(14)
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


extension UIColor {
    convenience init(hexString: String, alpha: CGFloat = 1.0) {
        let hexString: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        if hexString.hasPrefix("#") {
            scanner.currentIndex = hexString.index(hexString.startIndex, offsetBy: 1)
        }
        var color: UInt64 = 0
        scanner.scanHexInt64(&color)
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        let red = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue = CGFloat(b) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}

// TODO: - Add to shared file and remove from wallet and here
extension FileManager {
  static func sharedContainerURL() -> URL {
    return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.bink.wallet")!
}
}
