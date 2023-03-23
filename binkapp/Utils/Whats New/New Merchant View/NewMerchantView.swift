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
    enum Constants {
        static let cornerRadius: CGFloat = 12
        static let cardCornerRadius: CGFloat = 15
        static let cardWidth: CGFloat = 514.29
        static let cardHeight: CGFloat = 333.64
        static let secondaryRectXPos: CGFloat = 193
        static let secondaryRectYPos: CGFloat = 138.72
        static let secondaryRectRotation: CGFloat = -46
        static let primaryRectXPos: CGFloat = 216
        static let primaryRectYPos: CGFloat = 128.72
        static let primaryRectRotation: CGFloat = -23
        static let imageSize = CGSize(width: 70, height: 70)
        static let horizontalPadding: CGFloat = 20
        static let topPadding: CGFloat = 37
        static let outerFrameHeight: CGFloat = 120
        static let textStackLeadingPadding: CGFloat = 165
        static let textVerticalPadding: CGFloat = 3
        static let textHorizontalPadding: CGFloat = 10
        static let featureTextPadding: CGFloat = 10
    }
    
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
                RoundedRectangle(cornerRadius: Constants.cornerRadius, style: .continuous)
                    .foregroundColor(.white)
                /// --------------------------------------------------
                
                /// Secondary rect ------
                RoundedRectangle(cornerRadius: Constants.cardCornerRadius)
                    .frame(width: Constants.cardWidth, height: Constants.cardHeight)
                    .offset(x: Constants.secondaryRectXPos, y: Constants.secondaryRectYPos)
                    .rotationEffect(.degrees(Constants.secondaryRectRotation))
                    .foregroundColor(viewModel.secondaryColor)
                /// --------------------------------------------------
                
                /// Primary rect ------
                RoundedRectangle(cornerRadius: Constants.cardCornerRadius)
                    .frame(width: Constants.cardWidth, height: Constants.cardHeight)
                    .offset(x: Constants.primaryRectXPos, y: Constants.primaryRectYPos)
                    .rotationEffect(.degrees(Constants.primaryRectRotation))
                    .foregroundColor(viewModel.primaryColor)
                /// --------------------------------------------------
                
                /// Icon image stack ------
                HStack {
                    if let iconImage = viewModel.iconImage {
                        Image(uiImage: iconImage)
                            .resizable()
                            .frame(width: Constants.imageSize.width, height: Constants.imageSize.height, alignment: .center)
                            .cornerRadius(LayoutHelper.iconCornerRadius)
                    } else {
                        Image(uiImage: UIImage(named: "bink-icon-logo")!)
                            .resizable()
                            .frame(width: Constants.imageSize.width, height: Constants.imageSize.height, alignment: .center)
                            .cornerRadius(LayoutHelper.iconCornerRadius)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, Constants.horizontalPadding)
                .frame(width: width, height: Constants.outerFrameHeight)
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
                .padding(.top, Constants.topPadding)
                .padding(.leading, Constants.textStackLeadingPadding)
                .padding(.trailing, Constants.horizontalPadding)
                .frame(width: width, height: Constants.outerFrameHeight)
                /// --------------------------------------------------
                
                /// New retailer text
                HStack(alignment: .top) {
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("NEW RETAILER")
                            .font(.nunitoExtraBold(9))
                            .padding(.vertical, Constants.textVerticalPadding)
                            .padding(.horizontal, Constants.textHorizontalPadding)
                            .foregroundColor(.white)
                            .background(.white.opacity(0.3))
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                        
                        Spacer()
                    }
                }
                .padding(Constants.featureTextPadding)
                .frame(width: width, height: Constants.outerFrameHeight)
                /// --------------------------------------------------
                
                /// Disclosure image
                HStack {
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.white)
                }
                .frame(width: width, height: Constants.outerFrameHeight)
                .padding(.trailing, Constants.horizontalPadding)
                /// --------------------------------------------------
            }
            .frame(width: width, height: Constants.outerFrameHeight)
            .clipShape(
                RoundedRectangle(cornerRadius: Constants.cornerRadius, style: .continuous)
            )
        }
    }
}

struct NewMerchantView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color(uiColor: UIColor.primaryViewBackground).ignoresSafeArea()
            VStack {
                NewMerchantView(merchant: NewMerchantModel(id: "207", description: ["Sick new merchant", "Clubcards for the win"]), parentSize: CGSize(width: UIScreen.main.bounds.width, height: 0))
            }
        }
        .previewDevice(PreviewDevice(rawValue: "iPhone 14"))
        .previewDisplayName("iPhone 14")
    }
}
