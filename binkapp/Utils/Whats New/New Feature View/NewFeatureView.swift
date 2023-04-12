//
//  NewFeatureView.swift
//  binkapp
//
//  Created by Sean Williams on 02/03/2023.
//  Copyright © 2023 Bink. All rights reserved.
//

import SwiftUI

struct NewFeatureView: View {
    @ObservedObject var viewModel: NewFeatureViewModel
    let parentSize: CGSize

    init(viewModel: NewFeatureViewModel, parentSize: CGSize) {
        self.viewModel = viewModel
        self.parentSize = parentSize
    }
    
    var width: CGFloat {
        return parentSize.width
    }
    
    var body: some View {
        Button {
            if let screen = viewModel.deeplinkScreen {
                viewModel.navigate(to: screen)
            }
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .frame(maxHeight: 150)
                    .foregroundColor(viewModel.backgroundColor)
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        if let uiImage = viewModel.uiImage {
                            Image(uiImage: uiImage)
                                .resizable()
                                .frame(width: 35, height: 35)
                                .clipShape(Circle())
                        }
                        
                        Text(viewModel.feature.title ?? "")
                            .font(.nunitoBold(18))
                            .foregroundColor(viewModel.textColor)
                        
                        if let descriptionTexts = viewModel.descriptionTexts {
                            ForEach(descriptionTexts, id: \.self) { descriptionText in
                                Text(descriptionText)
                                    .font(.nunitoSans(12))
                                    .foregroundColor(viewModel.textColor)
                                    .multilineTextAlignment(.leading)
                            }
                        }
                    }
                    .padding(.vertical, 15)
                    
                    Spacer()
                    
                    if viewModel.hasDeeplink {
                        Image(systemName: "chevron.right")
                            .foregroundColor(.white)
                    }
                }
                .padding(.leading, 20)
                .padding(.trailing, 10)

                /// New retailer text
                HStack(alignment: .top) {
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("NEW FEATURE")
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
            }
            .frame(width: width, height: 120)
        }
    }
}

struct NewFeatureView_Previews: PreviewProvider {
    static var previews: some View {
        let newFeature = NewFeatureModel(id: nil, title: "Updates", description: ["My word this new feature is good"], screen: 2)
        NewFeatureView(viewModel: NewFeatureViewModel(feature: newFeature), parentSize: CGSize(width: UIScreen.main.bounds.width, height: 0))
    }
}
