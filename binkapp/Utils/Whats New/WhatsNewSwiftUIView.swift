//
//  WhatsNewSwiftUIView.swift
//  binkapp
//
//  Created by Sean Williams on 28/02/2023.
//  Copyright © 2023 Bink. All rights reserved.
//

import SwiftUI

struct WhatsNewSwiftUIView: View {
    @ObservedObject var viewModel: WhatsNewViewModel
    
    var body: some View {
        ScrollView {
            if let merchants = viewModel.merchants {
                ForEach(merchants) { merchant in
                    NewMerchantView(merchant: merchant)
                }
            }
            
            if let features = viewModel.features {
                ForEach(features) { feature in
                    NewFeatureView(feature: feature)
                }
            }
            
            Spacer()
        }
        .padding(.top, 20)
        .background(Color(uiColor: Current.themeManager.color(for: .viewBackground)))
        .navigationTitle("What's New?")
    }
}

struct NewMerchantView: View {
    @ObservedObject var viewModel: NewMerchantViewModel
    
    init(merchant: NewMerchantModel) {
        self.viewModel = NewMerchantViewModel(merchant: merchant)
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .frame(minHeight: 120)
                .foregroundColor(Color(uiColor: viewModel.backgroundColor))
            HStack(spacing: 20) {
                if let iconImage = viewModel.iconImage {
                    Image(uiImage: iconImage)
                        .resizable()
                        .frame(width: 70, height: 70, alignment: .center)
                        .cornerRadius(LayoutHelper.iconCornerRadius)
                }
//                else {
//                    Image(systemName: "lanyardcard")
//                        .resizable()
//                        .frame(width: 70, height: 70, alignment: .center)
//                }
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(viewModel.title)
                        .font(.nunitoBold(18))
                        .foregroundColor(viewModel.textColor)
                    
                    if let descriptionTexts = viewModel.descriptionTexts {
                        ForEach(descriptionTexts, id: \.self) { descriptionText in
                            Text(descriptionText)
                                .font(.nunitoSans(14))
                                .foregroundColor(viewModel.textColor)
                        }
                    }
                    

                    HStack {
                        Spacer()
                        Button {
                            viewModel.handleNavigation()
                        } label: {
                            Text("Take me there")
                                .font(.nunitoSemiBold(14))
                                .foregroundColor(viewModel.textColor)
                        }
                    }
                }
                
                Spacer()
            }
            .padding(.vertical, 10)
            .padding(.leading, 20)
        }
        .padding()
    }
}

class NewMerchantViewModel: ObservableObject {
    @Published var iconImage: UIImage?
    
    var merchant: NewMerchantModel
    var membershipPlan: CD_MembershipPlan?
    
    init(merchant: NewMerchantModel) {
        self.merchant = merchant
        self.membershipPlan = Current.wallet.membershipPlans?.first(where: { $0.id == merchant.id })
        getIconImage()
    }
    
    var title: String {
        return membershipPlan?.account?.companyName ?? "Tesco"
    }
    
    var descriptionTexts: [String]? {
        return merchant.description
    }
    
    var backgroundColor: UIColor {
        return membershipPlan?.secondaryBrandColor ?? .secondarySystemBackground
    }
    
    var textColor: Color {
        return backgroundColor.isLight(threshold: 0.8) ? .black : .white
    }
    
    func getMembershipPlan(from id: String) {
        membershipPlan = Current.wallet.membershipPlans?.first(where: { $0.id == id })
    }
    
    func getIconImage() {
        guard let membershipPlan = membershipPlan else { return }
        ImageService.getImage(forPathType: .membershipPlanIcon(plan: membershipPlan), completion: { image in
            self.iconImage = image ?? UIImage(named: "bink-icon-logo") ?? UIImage(systemName: "lanyardcard")
        })
    }
    
    func handleNavigation() {
        guard let membershipPlan = membershipPlan else { return }
        Current.navigate.close(animated: true) {
            let browseBrandsVC = ViewControllerFactory.makeBrowseBrandsViewController()
            let navigationRequest = ModalNavigationRequest(viewController: browseBrandsVC) {
                let addJoinVC = ViewControllerFactory.makeAddOrJoinViewController(membershipPlan: membershipPlan)
                let pushNavigationRequest = PushNavigationRequest(viewController: addJoinVC)
                Current.navigate.to(pushNavigationRequest)
            }
            Current.navigate.to(navigationRequest)
        }
    }
}

struct WhatsNewSwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            let merchant = NewMerchantModel(id: "207", description: ["Check out out lastest new merchant", "Sign up for a card in out app"])
            let feature = NewFeatureModel(title: "New Feature", description: "Check out this mint new feature yo.", screen: 0)
            let feature2 = NewFeatureModel(title: "New Feature", description: "Check out this mint new feature yo.", screen: 0)
            WhatsNewSwiftUIView(viewModel: WhatsNewViewModel(features: [feature, feature2], merchants: [merchant]))
        }
    }
}