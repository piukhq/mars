//
//  BrandTableView.swift
//  binkapp
//
//  Created by Sean Williams on 13/09/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import SwiftUI

struct BrandTableRowView: View {
    private enum Constants {
        static let rowHeight: CGFloat = 70
        static let padding: CGFloat = 10.0
        static let separatorHeight: CGFloat = 1.0
    }
    
    @ObservedObject var themeManager = Current.themeManager
    @ObservedObject var viewModel: BrandTableViewModel

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
                    }
                    
                    VStack {
                        HStack {
                            VStack(alignment: .leading) {
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
            
//            if viewModel.showSeparator {
//                Rectangle()
//                    .frame(height: Constants.separatorHeight)
//                    .foregroundColor(Color(themeManager.color(for: .divider)))
//                    .padding(.horizontal, 25)
//            }
        }
    }
}

//struct BrandTableView_Previews: PreviewProvider {
//    static var previews: some View {
//        BrandTableView()
//    }
//}

class BrandTableViewModel: ObservableObject {
    let title: String
    let plan: CD_MembershipPlan
    let brandExists: Bool
    let userInterfaceStyle: UIUserInterfaceStyle?
    var showSeparator: Bool
    let action: () -> Void
    
    @Published var image: UIImage?

    init(title: String, plan: CD_MembershipPlan, brandExists: Bool, userInterfaceStyle: UIUserInterfaceStyle? = nil, showSeparator: Bool, action: @escaping () -> Void) {
        self.title = title
        self.plan = plan
        self.brandExists = brandExists
        self.userInterfaceStyle = userInterfaceStyle
        self.showSeparator = showSeparator
        self.action = action
        getImage()
    }
    
    var subtitle: String? {
        return plan.featureSet?.planCardType == .link ? L10n.canBeLinkedDescription : nil
    }
    
    func getImage() {
        ImageService.getImage(forPathType: .membershipPlanIcon(plan: plan), userInterfaceStyle: userInterfaceStyle) { [weak self] image in
            self?.image = image
        }
    }
}
