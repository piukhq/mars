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

struct NewMerchantView_Previews: PreviewProvider {
    static var previews: some View {
        NewMerchantView(merchant: NewMerchantModel(id: "207", description: [""]))
    }
}
