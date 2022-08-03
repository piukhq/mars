//
//  SettingsView.swift
//  binkapp
//
//  Created by Sean Williams on 02/08/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    let viewModel: SettingsViewModel
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(0...(viewModel.sectionsCount - 1), id: \.self) { index in
                    let section = viewModel.sections[index]
                    Section(header: SettingsHeaderView(title: section.title)) {
                        ForEach(section.rows) { row in
                            SettingsRowView(rowData: row, showSeparator: viewModel.shouldShowSeparator(section: section, row: row))
                        }
                    }
                    .listSectionSeparator(.hidden)
                    .listRowSeparator(.hidden)
                    
                    Spacer()
                        .background(Color.red)
                        .frame(height: 40)
                        .foregroundColor(.purple)
                }
                
                Spacer()
                    .frame(height: 25)
                    .listSectionSeparator(.hidden)
                
                HStack {
                    Spacer()
                    VStack(alignment: .center) {
                        Text(Current.userManager.currentEmailAddress ?? "@gmail.com") /// Remove test strng <<<<<<<<<<<<<<<<<<<<<<<<<
                            .font(.custom(UIFont.navbarHeaderLine2.fontName, size: UIFont.navbarHeaderLine2.pointSize))
                            .foregroundColor(Color(UIColor.systemGray))
                        Text("Bink v\(Bundle.shortVersionNumber ?? "") \(Bundle.bundleVersion ?? "")")
                            .font(.custom(UIFont.navbarHeaderLine2.fontName, size: UIFont.navbarHeaderLine2.pointSize))
                            .foregroundColor(Color(UIColor.systemGray))
                    }
                    Spacer()
                }
                .listSectionSeparator(.hidden)
            }
            .padding(.horizontal, 25)
            .padding(.top, 25)
        }
        .navigationTitle("Settings")
    }
}

struct SettingsHeaderView: View {
    var title: String

    var body: some View {
        HStack {
            Text(title)
                .font(.custom(UIFont.headline.fontName, size: UIFont.headline.pointSize))
                .foregroundColor(Color(Current.themeManager.color(for: .text)))
            
            Spacer()
        }
        .frame(height: 30)
    }
}


struct SettingsRowView: View {
    var rowData: SettingsRow
    var showSeparator: Bool

    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text(rowData.title)
                        .font(.custom(UIFont.subtitle.fontName, size: UIFont.subtitle.pointSize))
                    if let subtitle = rowData.subtitle {
                        Text(subtitle)
                            .font(.custom(UIFont.bodyTextLarge.fontName, size: UIFont.bodyTextLarge.pointSize))
                    }
                }
                .frame(height: 70)
                
                Spacer()
                
                Image(uiImage: Asset.iconsChevronRight.image)
            }
            
            if showSeparator {
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(Color(Current.themeManager.color(for: .divider)))
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(viewModel: SettingsViewModel(rowsWithActionRequired: []))
    }
}
