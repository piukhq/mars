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
    MembershipCardWidget(id: "0", imageData: UIImage(named: "hn")?.pngData(), barCodeImage: UIImage(named: "hn")?.pngData(), backgroundColor: "#000000", planName: "Harvey Nichols"),
    MembershipCardWidget(id: "1", imageData: UIImage(named: "wasabi")?.pngData(), barCodeImage: UIImage(named: "wasabi")?.pngData(), backgroundColor: "#bed633", planName: "Wasabi"),
    MembershipCardWidget(id: "2", imageData: UIImage(named: "iceland")?.pngData(), barCodeImage: UIImage(named: "iceland")?.pngData(), backgroundColor: "#f80000", planName: "Iceland"),
    MembershipCardWidget(id: "addCard", imageData: nil, barCodeImage: nil, backgroundColor: nil, planName: nil)
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
        let entries = readWidgetContentsFromDisk()
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
    
    private func configureSnapshotEntry(context: Context) -> WidgetContent {
        let hasCurrentUser = UserDefaults(suiteName: WidgetType.quickLaunch.userDefaultsSuiteID)?.bool(forKey: "hasCurrentUser") ?? false
        var widgetContentFromDisk = readWidgetContentsFromDisk()

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
    
    private func readWidgetContentsFromDisk() -> [WidgetContent] {
        var contents: [WidgetContent] = []
        guard let archiveURL = FileManager.sharedContainerURL()?.appendingPathComponent("contents.json") else { return contents }
        
        let decoder = JSONDecoder()
        if let codeData = try? Data(contentsOf: archiveURL) {
            do {
                let widgetContent = try decoder.decode(WidgetContent.self, from: codeData)
                contents.append(widgetContent)
            } catch {
                BinkLogger.error(AppLoggerError.decodeWidgetContentsFromDiskFailure, value: error.localizedDescription)
            }
        }
        return contents
    }
}

struct BarcodeProvider: TimelineProvider {
    func placeholder(in context: Context) -> WidgetContent {
        configureSnapshotEntry(context: context)
    }

    func getSnapshot(in context: Context, completion: @escaping (WidgetContent) -> Void) {
        // Widget gallery
        completion(configureSnapshotEntry(context: context))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        let entries = readWidgetContentsFromDisk()
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
    
    private func configureSnapshotEntry(context: Context) -> WidgetContent {
        let hasCurrentUser = UserDefaults(suiteName: WidgetType.barcodeLaunch.userDefaultsSuiteID)?.bool(forKey: "hasCurrentUser") ?? false
        var widgetContentFromDisk = readWidgetContentsFromDisk()

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
    
    private func readWidgetContentsFromDisk() -> [WidgetContent] {
        print("readWidgetContentsFromDisk")
        var contents: [WidgetContent] = []
        guard let archiveURL = FileManager.sharedContainerURL()?.appendingPathComponent("contents.json") else { return contents }
        
        let decoder = JSONDecoder()
        if let codeData = try? Data(contentsOf: archiveURL) {
            do {
                let widgetContent = try decoder.decode(WidgetContent.self, from: codeData)
                contents.append(widgetContent)
            } catch {
                BinkLogger.error(AppLoggerError.decodeWidgetContentsFromDiskFailure, value: error.localizedDescription)
            }
        }
        return contents
    }
}


struct QuickLaunchEntryView: View {
    @Environment(\.widgetFamily) var family
    
    let model: QuickLaunchProvider.Entry

    var twoColumnGrid = [GridItem(.flexible(), alignment: .topLeading), GridItem(.flexible())]
    let hasCurrentUser = UserDefaults(suiteName: WidgetType.quickLaunch.userDefaultsSuiteID)?.bool(forKey: "hasCurrentUser") ?? false
    let url = URL(string: WidgetType.quickLaunch.rawValue + "://from_edge")
    
    enum Constants {
        static let widgetHeight: CGFloat = 164
        static let widgetPadding: CGFloat = 15
    }
    
    var body: some View {
        if hasCurrentUser || model.isPreview == true {
            LazyVGrid(columns: twoColumnGrid, alignment: .leading, spacing: 4) {
                ForEach(model.walletCards, id: \.self.id) { membershipCard in
                    switch membershipCard.id {
                    case WidgetUrlPath.addCard.rawValue:
                        AddCardView(membershipCard: membershipCard)
                    case WidgetUrlPath.spacerZero.rawValue, WidgetUrlPath.spacerOne.rawValue:
                        QuickLaunchWidgetGridSpacerView()
                    default:
                        WalletCardView(membershipCard: membershipCard)
                    }
                }
            }
            .frame(height: Constants.widgetHeight)
            .padding(.all, Constants.widgetPadding)
            .background(Color("binkBlue"))
            .widgetURL(url)
        } else {
            UnauthenticatedSwiftUIView().unredacted()
        }
    }
}

struct BarcodeQuickLaunchEntryView: View {
    @Environment(\.widgetFamily) var family
    
    let model: BarcodeProvider.Entry

    var oneColumnGrid = [GridItem(.flexible(), alignment: .topLeading)]
    let hasCurrentUser = UserDefaults(suiteName: WidgetType.barcodeLaunch.userDefaultsSuiteID)?.bool(forKey: "hasCurrentUser") ?? false
    let url = URL(string: WidgetType.barcodeLaunch.rawValue + "://from_edge")
    
    enum Constants {
        static let widgetHeight: CGFloat = 164
        static let widgetPadding: CGFloat = 15
    }
    
    var body: some View {
        if hasCurrentUser || model.isPreview == true {
            LazyVGrid(columns: oneColumnGrid, alignment: .leading, spacing: 0) {
                if let widget = model.walletCards.first {
                    switch widget.id {
                    case WidgetUrlPath.addCard.rawValue:
                        AddCardView(membershipCard: widget)
                    default:
                        WidgetBarcodeView(membershipCard: widget)
                    }
                }
            }
            .padding(.leading, 15)
            .padding(.trailing, 15)
            .padding(.top, 15)
            .padding(.bottom, 15)
            .background(Color("binkBlue"))
        } else {
            UnauthenticatedSwiftUIView().unredacted()
        }
    }
}

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

struct BinkWidget1: Widget {
    let kind: String = WidgetType.barcodeLaunch.identifier

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: BarcodeProvider()) { entry in
            BarcodeQuickLaunchEntryView(model: entry)
        }
        .configurationDisplayName("Barcode")
        .description("Quickly scan barcode.")
        .supportedFamilies([.systemMedium])
    }
}

@main
struct BinkWidgetBundle: WidgetBundle {
    @WidgetBundleBuilder
    var body: some Widget {
        BinkWidget()
        BinkWidget1()
    }
}

struct BinkWidget_Previews: PreviewProvider {
    static var previews: some View {
        BarcodeQuickLaunchEntryView(model: WidgetContent(walletCards: previewWalletCards, isPreview: true))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
            .preferredColorScheme(.light)
    }
}
