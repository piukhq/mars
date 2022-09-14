//
//  BrowseBrandsListView.swift
//  binkapp
//
//  Created by Sean Williams on 13/09/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import SwiftUI

struct BrowseBrandsListView: View {
    private enum Constants {
        static let separatorHeight: CGFloat = 1.0
        static let actionRequiredIndicatorHeight: CGFloat = 10
        static let padding: CGFloat = 30.0
    }
    
    @ObservedObject var themeManager = Current.themeManager
    @ObservedObject var viewModel: BrowseBrandsViewModel
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(viewModel.sections, id: \.self) { section in
//                    let section = viewModel.sections[index]
                    Section(header: SettingsHeaderView(title: "BELLO")) {
                        ForEach(section, id: \.self) { membershipPlan in
                            if let brandName = membershipPlan.account?.companyName, let brandExists = viewModel.existingCardsPlanIDs?.contains(membershipPlan.id) {
//                                let showSeparator = tableView.cellAtIndexPathIsLastInSection(indexPath) ? false : true
                                let brandViewModel = BrandTableViewModel(title: brandName, plan: membershipPlan, brandExists: brandExists, showSeparator: true) {
                                    viewModel.toAddOrJoinScreen(membershipPlan: membershipPlan)
                                }
                                BrandTableRowView(viewModel: brandViewModel)
                            }
                        }
                    }
                }
            }
            .background(Color.green)
        }
        .background(Color.purple)
        
//        VStack(spacing: 0) {
//            ForEach(0..<viewModel.informationRows.count) { index in
//                CardInformationRowView(rowData: viewModel.informationRows[index])
//
//                if showSeparator(index: index) {
//                    Rectangle()
//                        .frame(height: Constants.separatorHeight)
//                        .foregroundColor(Color(themeManager.color(for: .divider)))
//                }
//            }
//        }
//        .background(Color(Current.themeManager.color(for: .viewBackground)))
//        .padding(.horizontal, Constants.padding)
    }
    
//    private func showSeparator(index: Int) -> Bool {
//        return index == (viewModel.informationRows.count - 1) ? false : true
//    }
}

//struct BrowseBrandsListView_Previews: PreviewProvider {
//    static var previews: some View {
//        BrowseBrandsListView()
//    }
//}
