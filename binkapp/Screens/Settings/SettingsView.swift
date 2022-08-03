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
                        .frame(height: Constants.footerPadding)
                        .foregroundColor(.purple)
                }
                
                Spacer()
                    .frame(height: Constants.padding)
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
            .padding(.horizontal, Constants.padding)
            .padding(.top, Constants.padding)
        }
        .navigationTitle("Settings")
        .background(Color(Current.themeManager.color(for: .viewBackground)))
    }
}

struct SettingsHeaderView: View {
    var title: String

    var body: some View {
        HStack {
            Text(title)
                .font(.custom(UIFont.headline.fontName, size: UIFont.headline.pointSize))
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
    
    var rowData: SettingsRow
    var showSeparator: Bool
    
    func navigate<Content: View>(to view: Content) {
        let hostingViewController = UIHostingController(rootView: view)
        let navigationRequest = PushNavigationRequest(viewController: hostingViewController)
        Current.navigate.to(navigationRequest)
    }

    var body: some View {
        Button {
            switch rowData.action {
            case .customAction(let action):
                action()
            case .pushToSwiftUIView(swiftUIView: let swiftUIView):
                switch swiftUIView {
                case .whoWeAre:
                    navigate(to: WhoWeAreSwiftUIView())
                case .featureFlags:
                    navigate(to: FeatureFlagsSwiftUIView()) /// <<<<<<<<<<< Do we need delegate to refresh settings list after feature flags have updated
                case .debug:
                    navigate(to: DebugMenuView())
                }
//            case .pushToReusable(screen: let screen):
//                <#code#>
            case .logout:
                let alert = BinkAlertController(title: "Log out", message: "Are you sure you want to log out?", preferredStyle: .alert)
                alert.addAction(
                    UIAlertAction(title: "Log out", style: .default, handler: { _ in
                        NotificationCenter.default.post(name: .shouldLogout, object: nil)
                    })
                )
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                let navigationRequest = AlertNavigationRequest(alertController: alert)
                Current.navigate.to(navigationRequest)
            case .launchSupport(service: let service):
                switch service {
                case .faq:
                    BinkSupportUtility.launchFAQs()
                case .contactUs:
                    BinkSupportUtility.launchContactSupport()
                }
            case .delete:
                break
//                viewModel.handleRowActionForAccountDeletion()
            default:
                break
            }
        } label: {
            VStack {
                HStack {
                    VStack(alignment: .leading) {
                        Text(rowData.title)
                            .foregroundColor(Color(Current.themeManager.color(for: .text)))
                            .font(.custom(UIFont.subtitle.fontName, size: UIFont.subtitle.pointSize))
                        if let subtitle = rowData.subtitle {
                            Text(subtitle)
                                .font(.custom(UIFont.bodyTextLarge.fontName, size: UIFont.bodyTextLarge.pointSize))
                                .foregroundColor(Color(Current.themeManager.color(for: .text)))
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
                        .foregroundColor(Color(Current.themeManager.color(for: .text)))
                }
                
                if showSeparator {
                    Rectangle()
                        .frame(height: Constants.separatorHeight)
                        .foregroundColor(Color(Current.themeManager.color(for: .divider)))
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
