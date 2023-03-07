//
//  NewMerchantView.swift
//  binkapp
//
//  Created by Sean Williams on 03/03/2023.
//  Copyright © 2023 Bink. All rights reserved.
//

import SwiftUI


struct NewMerchantView: View {
    @ObservedObject var viewModel: NewMerchantViewModel
    var geometry: CGSize
    
    init(merchant: NewMerchantModel, geometry: CGSize) {
        self.viewModel = NewMerchantViewModel(merchant: merchant)
        self.geometry = geometry
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .foregroundColor(.white)
            
            RoundedRectangle(cornerRadius: 20)
                .frame(width: 514.29, height: 333.64)
                .offset(x: 204, y: 108.72)
                .rotationEffect(.degrees(-25))
                .foregroundColor(.purple)
            
            HStack(spacing: 50) {
                if let iconImage = viewModel.iconImage {
                    Image(uiImage: iconImage)
                        .resizable()
                        .frame(width: 70, height: 70, alignment: .center)
                        .cornerRadius(LayoutHelper.iconCornerRadius)
                } else {
                    Image(uiImage: UIImage(named: "bink-icon-logo")!)
                        .resizable()
                        .frame(width: 70, height: 70, alignment: .center)
                        .cornerRadius(LayoutHelper.iconCornerRadius)
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        VStack {
                            Text(viewModel.title)
                                .font(.nunitoBold(22))
                                .foregroundColor(viewModel.textColor)
                            
                            if let descriptionTexts = viewModel.descriptionTexts {
                                ForEach(descriptionTexts, id: \.self) { descriptionText in
                                    Text(descriptionText)
                                        .font(.nunitoSemiBold(12))
                                        .foregroundColor(viewModel.textColor)
                                }
                            }
                        }
                        
                        Spacer()
                            .frame(width: 5)
                        Button {
                            viewModel.handleNavigation()
                        } label: {
                            Image(systemName: "chevron.right")
                                .foregroundColor(viewModel.textColor)
                        }
                    }
                }
                
                Spacer()
            }
            .frame(width: geometry.width, height: 120)
            .padding(.vertical, 10)
            .padding(.leading, 40)
        }
        .frame(width: geometry.width, height: 120)
        .clipShape(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
        )
    }
}

struct NewMerchantView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color(uiColor: UIColor.primaryViewBackground).ignoresSafeArea()
            VStack {
                NewMerchantView(merchant: NewMerchantModel(id: "207", description: ["Check out out lastest new merchant", "Sign up for a card in our app"]), geometry: CGSizeMake(UIScreen.main.bounds.width, 0))
            }
            .padding(.horizontal, 25)
        }
    }
}
