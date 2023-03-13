//
//  NewMerchantView.swift
//  binkapp
//
//  Created by Sean Williams on 03/03/2023.
//  Copyright © 2023 Bink. All rights reserved.
//

import SwiftUI

// swiftlint:disable force_unwrapping

struct NewMerchantView: View {
    @ObservedObject var viewModel: NewMerchantViewModel
    var parentSize: CGSize
    
    init(merchant: NewMerchantModel, parentSize: CGSize) {
        self.viewModel = NewMerchantViewModel(merchant: merchant)
        self.parentSize = parentSize
    }
    
    var width: CGFloat {
        return parentSize.width
    }
    
    var body: some View {
        Button {
            viewModel.handleNavigation()
        } label: {
            ZStack {
                /// Main rect ------
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .foregroundColor(.white)
                /// --------------------------------------------------
                
                /// Secondary rect ------
                RoundedRectangle(cornerRadius: 15)
                    .frame(width: 514.29, height: 333.64)
                    .offset(x: 193, y: 138.72)
                    .rotationEffect(.degrees(-46))
                    .foregroundColor(viewModel.secondaryColor)
                /// --------------------------------------------------
                
                /// Primary rect ------
                RoundedRectangle(cornerRadius: 15)
                    .frame(width: 514.29, height: 333.64)
                    .offset(x: 216, y: 128.72)
                    .rotationEffect(.degrees(-23))
                    .foregroundColor(viewModel.primaryColor)
                /// --------------------------------------------------
                
                /// Icon image stack ------
                HStack {
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
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .frame(width: width, height: 120)
                /// --------------------------------------------------
                
                
                /// Text Stack ------
                HStack(alignment: .top, spacing: 10) {
                    VStack(alignment: .leading) {
                        Text(viewModel.title)
                            .font(.nunitoExtraBold(22))
                            .foregroundColor(viewModel.textColor)
                        
                        if let descriptionTexts = viewModel.descriptionTexts {
                            ForEach(descriptionTexts, id: \.self) { descriptionText in
                                Text(descriptionText)
                                    .font(.nunitoBold(10))
                                    .foregroundColor(viewModel.textColor)
                                    .multilineTextAlignment(.leading)
                            }
                        }
                        
                        Spacer()
                    }
                    
                    Spacer()
                }
                .padding(.top, 37)
                .padding(.leading, 165)
                .padding(.trailing, 20)
                .frame(width: width, height: 120)
                /// --------------------------------------------------
                
                /// New retailer text
                HStack(alignment: .top) {
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("NEW RETAILER")
                            .font(.nunitoExtraBold(9))
                            .padding(.vertical, 3)
                            .padding(.horizontal, 10)
                            .foregroundColor(.white)
                            .background(.white.opacity(0.3))
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                        
                        Spacer()
                    }
                }
                .padding(10)
                .frame(width: width, height: 120)
                /// --------------------------------------------------
                
                /// Disclosure image
                HStack {
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.white)
                }
                .frame(width: width, height: 120)
                .padding(.trailing, 20)
                /// --------------------------------------------------
            }
            .frame(width: width, height: 120)
            .clipShape(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
            )
        }
    }
}

struct NewMerchantView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color(uiColor: UIColor.primaryViewBackground).ignoresSafeArea()
            VStack {
                NewMerchantView(merchant: NewMerchantModel(id: "207", description: ["Sick new merchant", "Clubcards for the win"]), parentSize: CGSizeMake(UIScreen.main.bounds.width, 0))
            }
        }
        .previewDevice(PreviewDevice(rawValue: "iPhone 14"))
        .previewDisplayName("iPhone 14")
    }
}
