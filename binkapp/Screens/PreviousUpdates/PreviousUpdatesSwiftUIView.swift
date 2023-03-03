//
//  PreviousUpdatesSwiftUIView.swift
//  binkapp
//
//  Created by Ricardo Silva on 03/03/2023.
//  Copyright © 2023 Bink. All rights reserved.
//

import SwiftUI

struct ReleaseNote: Codable {
    let note: String
}

struct Release: Codable, Identifiable {
    var id = UUID()
    let name: String
    var updateName: String?
    var icon: String?
    var items: [Release]?

    // some example websites
    static let apple = Release(name: "Tis is a massive long text and is just to infor the user that something has changed", icon: "circle.fill")
    static let bbc = Release(name: "Fixed bug in Wallet", icon: "circle.fill")
    static let swift = Release(name: "Colour fix in settings", icon: "circle.fill")
    static let twitter = Release(name: "Go to site button now moved to the loyalty card details screen", icon: "circle.fill")

    // some example groups
    static let example1 = Release(name: "Version 2.3.28 - 27/02/2023", items: [Release.apple, Release.bbc, Release.swift, Release.twitter])
    static let example2 = Release(name: "Version 2.3.27 - 12/12/2022", items: [Release.apple, Release.bbc, Release.swift, Release.twitter])
    static let example3 = Release(name: "Version 2.3.26 - 4/8/2022", items: [Release.apple, Release.bbc, Release.swift, Release.twitter])
}

struct PreviousUpdatesSwiftUIView: View {
    let items: [Release] = [.example1, .example2, .example3]
    
    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Text("Release Notes")
                        .foregroundColor(Color(Current.themeManager.color(for: .text)))
                        .uiFont(.headline)
                    Spacer()
                }
                
                ForEach(items, id: \.id) { name in
                    DisclosureGroup(
                        content: {
                            ForEach(name.items!, id: \.id) { row in
                                HStack {
                                    if let icon = row.icon {
                                        Image(systemName: icon)
                                            .resizable()
                                            .frame(width: 6, height: 6)
                                    }
                                    
                                    Text(row.name)
                                    Spacer()
                                }
                                .padding(6)
                            }
                        },
                        label: {
                            HStack {
                                Text(name.name)
                                    .foregroundColor(.white)
                                Spacer()
                            }
                        }
                    )
                    .padding()
                    .border(.white, width: 2)
                    .cornerRadius(4)
                    .accentColor(.white)
                }
            }
            .padding()
        }
    } // body

//    var body: some View {
//
//        List(items, children: \.items) { row in
//            HStack {
//                Image(systemName: row.icon)
//                    .resizable()
//                    .frame(width: 6, height: 6)
//                Text(row.name)
//            }
//        }
//    }
}


struct PreviousUpdatesSwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        PreviousUpdatesSwiftUIView()
    }
}
