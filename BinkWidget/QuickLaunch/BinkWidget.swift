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
    MembershipCardWidget(id: "0", imageData: UIImage(named: "hn")?.pngData(), backgroundColor: "#000000"),
    MembershipCardWidget(id: "1", imageData: UIImage(named: "wasabi")?.pngData(), backgroundColor: "#bed633"),
    MembershipCardWidget(id: "2", imageData: UIImage(named: "iceland")?.pngData(), backgroundColor: "#f80000"),
    MembershipCardWidget(id: "addCard", imageData: nil, backgroundColor: nil)
]

struct QuickLaunchProvider: TimelineProvider {
    func placeholder(in context: Context) -> WidgetContent {
        configureSnapshotEntry(context: context)
    }

    func getSnapshot(in context: Context, completion: @escaping (WidgetContent) -> Void) {
        // Widget gallery
        completion(configureSnapshotEntry(context: context))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        let entries = readContents()
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
    
    private func configureSnapshotEntry(context: Context) -> WidgetContent {
        let hasCurrentUser = UserDefaults(suiteName: WidgetType.quickLaunch.userDefaultsSuiteID)?.bool(forKey: "hasCurrentUser") ?? false
        var widgetContentFromDisk = readContents()

        if widgetContentFromDisk.isEmpty {
            // Nothing on disk - e.g. first launch
            return WidgetContent(walletCards: previewWalletCards, isPreview: context.isPreview)
        } else if widgetContentFromDisk[0].walletCards.first?.id == WidgetUrlPath.addCard.rawValue {
            // Empty wallet state - single cell with plus button
            return WidgetContent(walletCards: previewWalletCards, isPreview: context.isPreview)
        } else {
            // User has cards in wallet
            widgetContentFromDisk[0].isPreview = hasCurrentUser == true ? false : true
            return widgetContentFromDisk[0]
        }
    }
    
    private func readContents() -> [WidgetContent] {
        var contents: [WidgetContent] = []
        let archiveURL = FileManager.sharedContainerURL().appendingPathComponent("contents.json")
        
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

    var twoColumnGrid = [GridItem(.flexible(), alignment: .topLeading), GridItem(.flexible())]
    let hasCurrentUser = UserDefaults(suiteName: WidgetType.quickLaunch.userDefaultsSuiteID)?.bool(forKey: "hasCurrentUser") ?? false
    
    var body: some View {
        if hasCurrentUser || model.isPreview == true {
            LazyVGrid(columns: twoColumnGrid, alignment: .leading, spacing: 4) {
                ForEach(model.walletCards, id: \.self.id) { membershipCard in
                    switch membershipCard.id {
                    case WidgetUrlPath.addCard.rawValue:
                        AddCardView(membershipCard: membershipCard)
                    case WidgetUrlPath.spacerZero.rawValue, WidgetUrlPath.spacerOne.rawValue:
                        SpacerView()
                    default:
                        WalletCardView(membershipCard: membershipCard)
                    }
                }
            }
            .frame(height: 164)
            .padding(.all, 15.0)
            .background(Color("WidgetBackground"))
        } else {
            UnauthenticatedSwiftUIView().unredacted()
        }
    }
}

@main
struct BinkWidget: Widget {
    let kind: String = WidgetType.quickLaunch.identifier

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: QuickLaunchProvider()) { entry in
            QuickLaunchEntryView(model: entry)
        }
        .configurationDisplayName("Quick Launch")
        .description("Quickly access your favourite loyalty cards.")
        .supportedFamilies([.systemMedium])
    }
}

struct BinkWidget_Previews: PreviewProvider {
    static var previews: some View {
        QuickLaunchEntryView(model: WidgetContent(walletCards: previewWalletCards, isPreview: true))
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
