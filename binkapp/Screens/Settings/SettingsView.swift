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
        List {
            ForEach(0...(viewModel.sectionsCount - 1), id: \.self) { index in
                let section = viewModel.sections[index]
                Section(header: SettingsHeaderView(title: section.title)) {
                    ForEach(section.rows) { row in
                        SettingsRowView(rowData: row)
                    }
                }
                .listSectionSeparator(.hidden)
            }
        }
        .listStyle(.plain)
        .listSectionSeparator(.hidden)
        .listSectionSeparatorTint(.red)
        .navigationBarTitle("Settings")
    }
}

struct SettingsHeaderView: View {
    var title: String

    var body: some View {
        Text(title)
            .font(.custom(UIFont.headline.fontName, size: UIFont.headline.pointSize))
            .foregroundColor(Color(Current.themeManager.color(for: .text)))
    }
}


struct SettingsRowView: View {
    var rowData: SettingsRow

    var body: some View {
        VStack(alignment: .leading) {
            Text(rowData.title)
                .font(.custom(UIFont.subtitle.fontName, size: UIFont.subtitle.pointSize))
            if let subtitle = rowData.subtitle {
                Text(subtitle)
                    .font(.custom(UIFont.bodyTextLarge.fontName, size: UIFont.bodyTextLarge.pointSize))
            }
        }
        .frame(height: 70)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(viewModel: SettingsViewModel(rowsWithActionRequired: []))
    }
}
