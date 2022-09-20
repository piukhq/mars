//
//  BrandTableView.swift
//  binkapp
//
//  Created by Sean Williams on 13/09/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import SwiftUI

struct BrowseBrandsListRowView: View {
    private enum Constants {
        static let rowHeight: CGFloat = 70
        static let padding: CGFloat = 10.0
        static let separatorHeight: CGFloat = 1.0
    }
    
    @ObservedObject var themeManager = Current.themeManager
    @ObservedObject var viewModel: BrowseBrandsListRowViewModel

    var body: some View {
        VStack(spacing: 0) {
            Button {
                viewModel.action()
            } label: {
                HStack(spacing: 15) {
                    if let image = viewModel.image {
                        Image(uiImage: image)
                            .resizable()
                            .frame(width: 64, height: 64)
                            .cornerRadius(LayoutHelper.iconCornerRadius)
                    } else {
                        RoundedRectangle(cornerRadius: LayoutHelper.iconCornerRadius, style: .continuous)
                            .fill(.white)
                            .frame(width: 64, height: 64)
                    }
                    
                    VStack {
                        HStack {
                            VStack(alignment: .leading, spacing: 5) {
                                HStack {
                                    Text(viewModel.title)
                                        .foregroundColor(Color(themeManager.color(for: .text)))
                                        .uiFont(.subtitle)
                                    if viewModel.brandExists {
                                        Image(Asset.existingSchemeIcon.name)
                                            .frame(width: 23, height: 16)
                                    }
                                }
                                if let subtitle = viewModel.subtitle {
                                    Text(subtitle)
                                        .uiFont(.bodyTextSmall)
                                        .foregroundColor(Color(themeManager.color(for: .text)))
                                }
                            }
                            .frame(height: Constants.rowHeight)
                            
                            Spacer()
                            
                            Image(uiImage: Asset.iconsChevronRight.image)
                                .foregroundColor(Color(themeManager.color(for: .text)))
                        }
                        .padding(.vertical, Constants.padding)
                    }
                }
            }
            .padding(.horizontal, 25)
            .background(Color(Current.themeManager.color(for: .viewBackground)))
        }
    }
}
