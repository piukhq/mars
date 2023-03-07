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
                
                ForEach(viewModel.items, id: \.id) { release in
                    DisclosureGroup(
                        content: {
                            ForEach(release.releaseNotes ?? [], id: \.id) { group in
                                VStack {
                                    HStack {
                                        Text(group.heading ?? "Heading")
                                            .uiFont(.linkTextButtonNormal)
                                            .foregroundColor(Color(Current.themeManager.color(for: .text)))
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
                                                .foregroundColor(Color(Current.themeManager.color(for: .text)))
                                            Spacer()
                                        }
                                        .padding(.leading, 6)
                                    }
                                }
                            }
                        },
                        label: {
                            HStack {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                                        .fill((Color(UIColor.binkBlueTitleText)
                                            .opacity(0.4)))
                                        .frame(width: 26, height: 26)
                                    Image(systemName: "gearshape")
                                        .resizable()
                                        .frame(width: 16, height: 16)
                                        .foregroundColor(Color(UIColor.binkBlueTitleText))
                                }
                                
                                Text(release.releaseTitle ?? "Title")
                                    .uiFont(.textFieldLabel)
                                    .lineLimit(1)
                                    .foregroundColor(Color(Current.themeManager.color(for: .text)))
                                
                                Spacer()
                            }
                        }
                    )
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12)
                        .fill(Color(Current.themeManager.color(for: .walletCardBackground))))
                    .accentColor(Color(Current.themeManager.color(for: .text)))
                }
            }
            .padding()
        }
        .background(Color(Current.themeManager.color(for: .viewBackground)))
    }
}


struct PreviousUpdatesSwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        PreviousUpdatesSwiftUIView(viewModel: PreviousUpdatesViewModel())
    }
}
