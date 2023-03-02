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
    }
}

struct NewMerchantView: View {
    var viewModel: NewMerchantViewModel
    
    init(merchant: NewMerchantModel) {
        self.viewModel = NewMerchantViewModel(merchant: merchant)
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .frame(minHeight: 120)
                .foregroundColor(Color(.secondarySystemBackground))
//                .foregroundColor(Color(Current.themeManager.color(for: .text)))
            HStack(spacing: 20) {
                if let iconImage = viewModel.iconImage {
                    Image(uiImage: iconImage)
                        .resizable()
                        .frame(width: 70, height: 70, alignment: .center)
                } else {
                    Image(systemName: "lanyardcard")
                        .resizable()
                        .frame(width: 70, height: 70, alignment: .center)
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(viewModel.title)
                        .font(.nunitoBold(18))
                    
                    if let descriptionTexts = viewModel.descriptionTexts {
                        ForEach(descriptionTexts, id: \.self) { descriptionText in
                            Text(descriptionText)
                                .font(.nunitoSans(14))
                        }
                    }
                    
                    if let _ = viewModel.url {
                        HStack {
                            Spacer()
                            Button {
                                print("Button Tapped")
                            } label: {
                                Text("Take me there")
                                    .font(.nunitoSemiBold(14))
                            }
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
    
    var url: String? {
        return merchant.url
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
}

struct NewFeatureView: View {
    var feature: NewFeatureModel
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .frame(height: 120)
                .foregroundColor(Color(.secondarySystemBackground))
//                .foregroundColor(Color(Current.themeManager.color(for: .text)))
            HStack {
                VStack(alignment: .leading, spacing: 10) {
                    Text(feature.title ?? "Title")
                        .font(.nunitoBold(20))
                    Text(feature.description ?? "This summary, which briefly sets out your rights and obligations in relation to administration charges")
                        .font(.nunitoSans(16))
                    
                    if let _ = feature.url {
                        HStack {
                            Spacer()
                            Button {
                                print("Button Tapped")
                            } label: {
                                Text("Take me there")
                                    .font(.nunitoSemiBold(16))
                            }
                        }
                    }
                }
                .padding(20)
                
                Spacer()
            }
        }
        .padding()
    }
}

struct WhatsNewSwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            let merchant = NewMerchantModel(id: "207", description: ["Check out out lastest new merchant", "Sign up for a card in out app"], url: "")
            let feature = NewFeatureModel(title: "New Feature", description: "Check out this mint new feature yo.", url: nil)
            let feature2 = NewFeatureModel(title: "New Feature", description: "Check out this mint new feature yo.", url: "")
            WhatsNewSwiftUIView(viewModel: WhatsNewViewModel(features: [feature, feature2], merchants: [merchant]))
        }
    }
}
