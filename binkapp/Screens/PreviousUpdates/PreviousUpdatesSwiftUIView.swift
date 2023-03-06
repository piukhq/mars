//
//  PreviousUpdatesSwiftUIView.swift
//  binkapp
//
//  Created by Ricardo Silva on 03/03/2023.
//  Copyright © 2023 Bink. All rights reserved.
//

import SwiftUI

struct PreviousUpdatesSwiftUIView: View {
    @ObservedObject var viewModel: PreviousUpdatesViewModel
    
    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Text("Previous Updates")
                        .foregroundColor(Color(Current.themeManager.color(for: .text)))
                        .uiFont(.headline)
                    Spacer()
                }
                
                ForEach(viewModel.items ?? [], id: \.id) { release in
                    DisclosureGroup(
                        content: {
                            ForEach(release.releaseNotes ?? [], id: \.id) { group in
                                VStack {
                                    HStack {
                                        Text(group.heading ?? "Heading")
                                            .uiFont(.subtitle)
                                            .foregroundColor(.white)
                                        Spacer()
                                    }
                                    .padding(.top, 18)
                                    
                                    ForEach(group.bulletPoints ?? [], id: \.self) { note in
                                        HStack {
                                            Image(systemName: "circle.fill")
                                                .resizable()
                                                .frame(width: 6, height: 6)
                                            Text(note)
                                                .uiFont(.bodyTextSmall)
                                                .foregroundColor(.white)
                                            Spacer()
                                        }
                                    }
                                }
                            }
                        },
                        label: {
                            HStack {
                                Text(release.releaseTitle ?? "Title")
                                    .uiFont(.miniButtonText)
                                    .lineLimit(1)
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
    }
}


struct PreviousUpdatesSwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        PreviousUpdatesSwiftUIView(viewModel: PreviousUpdatesViewModel())
    }
}
