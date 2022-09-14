//
//  BrowseBrandsHeaderView.swift
//  binkapp
//
//  Created by Sean Williams on 14/09/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import SwiftUI

struct BrowseBrandsHeaderView: View {
    var viewModel: BrowseBrandsViewModel
    var section: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(viewModel.getSectionTitleText(section: section))
                .uiFont(.headline)
                .foregroundColor(Color(Current.themeManager.color(for: .text)))
            Text(viewModel.getSectionDescriptionText(section: section))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 25)
    }
}

struct BrowseBrandsHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        BrowseBrandsHeaderView(viewModel: BrowseBrandsViewModel(), section: 0)
    }
}
