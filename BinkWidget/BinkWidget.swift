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
        configureSnapshotEntry()
    }

    func getSnapshot(in context: Context, completion: @escaping (WidgetContent) -> Void) {
        // Widget gallery
        completion(configureSnapshotEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        let entries = readContents()
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
    
    private func configureSnapshotEntry() -> WidgetContent {
        var widgetContentFromDisk = readContents()[0]
        if widgetContentFromDisk.walletCards.first?.id == WidgetUrlPath.addCard.rawValue {
            // Empty wallet state
            return WidgetContent(walletCards: previewWalletCards, isPreview: true)
        } else {
            widgetContentFromDisk.isPreview = true
            return widgetContentFromDisk
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

struct WalletCardView: View {
    let membershipCard: MembershipCardWidget
    
    var body: some View {
        Link(destination: membershipCard.url) {
            HStack(alignment: .center, spacing: 0) {
                if let imageData = membershipCard.imageData, let uiImage = UIImage(data: imageData) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .frame(width: 39, height: 39, alignment: .center)
                            .foregroundColor(.white)
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 36.0, height: 36.0)
                            .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                    }.shadow(color: Color(.displayP3, white: 2, opacity: 0.5), radius: 2, x: 1.0, y: 1.0)
                    Spacer()
                } else {
                    RoundedRectangle(cornerRadius: 5)
                        .frame(width: 36, height: 36, alignment: .center)
                        .foregroundColor(Color(UIColor(hexString: "#FFFFFF", alpha: 0.5)))
                    Spacer()
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12.0, style: .continuous)
                    .frame(minWidth: 153, maxWidth: .infinity, minHeight: 64)
                    .foregroundColor(Color(UIColor(hexString: membershipCard.backgroundColor ?? "#009190")))
            )
        }
    }
}

struct AddCardView: View {
    let membershipCard: MembershipCardWidget

    var body: some View {
        Link(destination: membershipCard.url) {
            HStack(alignment: .center, spacing: 0) {
                Spacer()
                Image(systemName: "plus")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20.0, height: 36.0)
                    .foregroundColor(.white)
                Spacer()
            }
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.gray, lineWidth: 1)
            )
            .background(
                RoundedRectangle(cornerRadius: 12.0, style: .continuous)
                    .frame(minWidth: 153, maxWidth: .infinity, minHeight: 64)
                    .foregroundColor(Color(.clear))
            )
        }
    }
}

struct SpacerView: View {
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            Spacer().frame(width: 20, height: 36, alignment: .center)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12.0)
                .frame(minWidth: 153, maxWidth: .infinity, minHeight: 64)
                .foregroundColor(Color(.clear))
        )
    }
}

struct QuickLaunchEntryView: View {
    let model: QuickLaunchProvider.Entry

    var twoColumnGrid = [GridItem(.flexible(), alignment: .topLeading), GridItem(.flexible())]
    let hasCurrentUser = UserDefaults(suiteName: "group.com.bink.wallet")?.bool(forKey: "hasCurrentUser") ?? false
    
    var body: some View {
        if hasCurrentUser || model.isPreview == true {
            LazyVGrid(columns: twoColumnGrid, alignment: .leading, spacing: 5) {
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
