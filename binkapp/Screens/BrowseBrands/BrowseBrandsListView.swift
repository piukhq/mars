//
//  BrowseBrandsListView.swift
//  binkapp
//
//  Created by Sean Williams on 13/09/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import SwiftUI
import StoreKit

struct BrowseBrandsListView: View {
    private enum Constants {
        static let separatorHeight: CGFloat = 1.0
        static let actionRequiredIndicatorHeight: CGFloat = 10
        static let padding: CGFloat = 30.0
    }
    
    enum SectionID: String {
        case pll
        case see
        case store
    }
    
    @ObservedObject var themeManager = Current.themeManager
    @ObservedObject var viewModel: BrowseBrandsViewModel
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 0) {
                    if viewModel.shouldShowNoResultsLabel {
                        ScanLoyaltyCardButtonView(viewModel: ScanLoyaltyCardButtonViewModel(type: .custom))
                        Text(L10n.noMatches)
                            .uiFont(.bodyTextLarge)
                            .foregroundColor(Color(Current.themeManager.color(for: .text)))
                            .padding(.top, 30)
                    } else {
                        ForEach(0..<viewModel.sections.count, id: \.self) { sectionIndex in
                            let sectionData = viewModel.sections[sectionIndex]
                            if !sectionData.isEmpty {
                                BrowseBrandsHeaderView(viewModel: viewModel, section: sectionIndex).id(idForSection(sectionIndex))
                            }
                            
                            ForEach(0..<sectionData.count, id: \.self) { index in
                                if let membershipPlan = sectionData[safe: index], let brandName = membershipPlan.account?.companyName, let brandExists = viewModel.existingCardsPlanIDs?.contains(membershipPlan.id) {
                                    let brandViewModel = BrowseBrandsListRowViewModel(title: brandName, plan: membershipPlan, brandExists: brandExists, showSeparator: true) {
                                        viewModel.toAddOrJoinScreen(membershipPlan: membershipPlan)
                                    }
                                    
                                    VStack(spacing: 0) {
                                        BrowseBrandsListRowView(viewModel: brandViewModel)
                                        
                                        if shouldShowSeparator(index: index, rowsInsection: sectionData.count) {
                                            Rectangle()
                                                .fill(Color(themeManager.color(for: .divider)))
                                                .frame(height: Constants.separatorHeight)
                                                .padding(.horizontal, 25)
                                        }
                                    }
                                }
                            }
                        }
                        
                        ScanLoyaltyCardButtonView(viewModel: ScanLoyaltyCardButtonViewModel(type: .custom))
                    }
                }
                .background(Color(Current.themeManager.color(for: .viewBackground)))
            }
            .background(Color(Current.themeManager.color(for: .viewBackground)))
            .onReceive(viewModel.$scrollToSection) { section in
                withAnimation {
                    proxy.scrollTo(idForSection(section), anchor: .top)
                }
            }
        }
    }

    private func idForSection(_ id: Int) -> SectionID {
        switch id {
        case 0:
            return .pll
        case 1:
            return .see
        case 2:
            return .store
        default:
            return .pll
        }
    }
    
    private func shouldShowSeparator(index: Int, rowsInsection: Int) -> Bool {
        return index == (rowsInsection - 1) ? false : true
    }
}
