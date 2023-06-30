//
//  PreviousUpdatesViewModel.swift
//  binkapp
//
//  Created by Ricardo Silva on 06/03/2023.
//  Copyright © 2023 Bink. All rights reserved.
//

import Foundation
import UIKit
import FirebaseFirestoreSwift

struct ReleaseNotes: Codable {
    let releases: [ReleaseGroup]?
    
    struct ReleaseNotesGroup: Codable, Identifiable {
        var id = UUID()
        var heading: String?
        var bulletPoints: [String]?
        
        enum CodingKeys: String, CodingKey {
            case heading
            case bulletPoints = "bullet_points"
        }
    }

    struct ReleaseGroup: Codable, Identifiable {
        var id = UUID()
        var releaseTitle: String?
        var releaseNotes: [ReleaseNotesGroup]?
        
        enum CodingKeys: String, CodingKey {
            case releaseTitle = "release_title"
            case releaseNotes = "release_notes"
        }
    }
}

class PreviousUpdatesViewModel: ObservableObject {
    @Published var items: [ReleaseNotes.ReleaseGroup] = []
    
    init() {
        if !UIApplication.isRunningUnitTests {
            guard let collectionReference = Current.firestoreManager.getCollection(collection: .releaseNotes) else { return }
            
            let query = collectionReference.whereField("platform", isEqualTo: "iOS")
            Current.firestoreManager.fetchDocumentsInCollection(ReleaseNotes.self, query: query, completion: { [weak self] snapshot in
                if let doc = snapshot?.first {
                    self?.items = doc.releases ?? []
                }
            })
        }
    }
}
