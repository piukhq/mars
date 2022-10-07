//
//  SettingsView.swift
//  binkapp
//
//  Created by Sean Williams on 02/08/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    private enum Constants {
        static let padding: CGFloat = 25.0
        static let footerPadding: CGFloat = 40.0
    }
    
    @ObservedObject var viewModel: SettingsViewModel
    @ObservedObject var themeManager = Current.themeManager

    var body: some View {
        ScrollView {
            VStack {
                ForEach(0...(viewModel.sectionsCount - 1), id: \.self) { index in
                    let section = viewModel.sections[index]
                    Section(header: SettingsHeaderView(title: section.title)) {
                        ForEach(section.rows) { row in
                            SettingsRowView(rowData: row, viewModel: viewModel, showSeparator: viewModel.shouldShowSeparator(section: section, row: row))
                        }
                    }
                    .listSectionSeparator(.hidden)
                    .listRowSeparator(.hidden)
                    
                    Spacer()
                        .background(Color.red)
                        .frame(height: Constants.footerPadding)
                        .foregroundColor(.purple)
                }
                
                Spacer()
                    .frame(height: Constants.padding)
                    .listSectionSeparator(.hidden)
                
                HStack {
                    Spacer()
                    VStack(alignment: .center) {
                        Text(Current.userManager.currentEmailAddress ?? "")
                            .uiFont(.navbarHeaderLine2)
                            .foregroundColor(Color(UIColor.systemGray))
                        Text("Bink v\(Bundle.shortVersionNumber ?? "") \(Bundle.bundleVersion ?? "")")
                            .uiFont(.navbarHeaderLine2)
                            .foregroundColor(Color(UIColor.systemGray))
                    }
                    Spacer()
                }
                .listSectionSeparator(.hidden)
            }
            .padding(Constants.padding)
        }
        .navigationTitle("Settings")
        .background(Color(themeManager.color(for: .viewBackground)))
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct SettingsHeaderView: View {
    var title: String

    var body: some View {
        HStack {
            Text(title)
                .uiFont(.headline)
                .foregroundColor(Color(UIColor.binkBlueTitleText))

            Spacer()
        }
        .frame(height: 30)
    }
}


struct SettingsRowView: View {
    private enum Constants {
        static let rowHeight: CGFloat = 70
        static let separatorHeight: CGFloat = 1.0
        static let actionRequiredIndicatorHeight: CGFloat = 10
        static let padding: CGFloat = 20.0
    }
    
    @ObservedObject var themeManager = Current.themeManager
    var rowData: SettingsRow
    var viewModel: SettingsViewModel
    var showSeparator: Bool
    
    var body: some View {
        Button {
            viewModel.handleRowAction(for: rowData)
        } label: {
            VStack {
                HStack {
                    VStack(alignment: .leading) {
                        Text(rowData.title)
                            .foregroundColor(Color(themeManager.color(for: .text)))
                            .uiFont(.subtitle)
                        if let subtitle = rowData.subtitle {
                            Text(subtitle)
                                .uiFont(.bodyTextLarge)
                                .foregroundColor(Color(themeManager.color(for: .text)))
                        }
                    }
                    .frame(height: Constants.rowHeight)
                    
                    Spacer()
                    
                    if rowData.actionRequired {
                        Circle()
                            .frame(width: Constants.actionRequiredIndicatorHeight, height: Constants.actionRequiredIndicatorHeight, alignment: .center)
                            .foregroundColor(Color(uiColor: .systemRed))
                            .padding(.trailing, Constants.padding)
                    }
                    
                    Image(uiImage: Asset.iconsChevronRight.image)
                        .foregroundColor(Color(themeManager.color(for: .text)))
                }
                
                if showSeparator {
                    Rectangle()
                        .frame(height: Constants.separatorHeight)
                        .foregroundColor(Color(themeManager.color(for: .divider)))
                }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(viewModel: SettingsViewModel(rowsWithActionRequired: []))
    }
}
