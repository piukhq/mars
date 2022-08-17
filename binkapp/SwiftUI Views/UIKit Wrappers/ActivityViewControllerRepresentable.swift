//
//  ActivityViewControllerRepresentable.swift
//  binkapp
//
//  Created by Sean Williams on 17/08/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import LinkPresentation
import SwiftUI

struct ActivityViewController: UIViewControllerRepresentable {
    let activityItemMetadata: LinkMetadataManager
    var applicationActivities: [UIActivity]?
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityViewController>) -> UIActivityViewController {
        return UIActivityViewController(activityItems: [activityItemMetadata], applicationActivities: applicationActivities)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityViewController>) {}
}

final class LinkMetadataManager: NSObject, UIActivityItemSource {
    let linkMetadata: LPLinkMetadata
    let title: String
    let url: URL
    
    init(title: String, url: URL) {
        self.linkMetadata = LPLinkMetadata()
        self.title = title
        self.url = url
    }
}

extension LinkMetadataManager {
    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        linkMetadata.originalURL = url
        linkMetadata.url = linkMetadata.originalURL
        linkMetadata.title = title
        linkMetadata.iconProvider = NSItemProvider(
            contentsOf: Bundle.main.url(forResource: "AppIcon", withExtension: "png"))
        
        return linkMetadata
    }
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return ""
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return linkMetadata.url
    }
}
