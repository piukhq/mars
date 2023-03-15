//
//  ScanLoyaltyCardButtonView.swift
//  binkapp
//
//  Created by Sean Williams on 14/09/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import SwiftUI
import Lottie

struct ScanLoyaltyCardButtonView: View {
    var viewModel: ScanLoyaltyCardButtonViewModel
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10.0, style: .continuous)
                .fill(LinearGradient(gradient: Gradient(colors: [Color(.binkGradientBlueRight), Color(.binkGradientBlueLeft)]), startPoint: .leading, endPoint: .trailing))
            HStack(spacing: 15) {
                Image(uiImage: Asset.scanQuick.image)
                    .resizable()
                    .frame(width: 50, height: 50)
                
                VStack(alignment: .leading) {
                    Text(viewModel.title)
                        .font(.nunitoExtraBold(20))
                        .foregroundColor(.white)
                    Text(viewModel.subtitle)
                        .font(.nunitoSans(15))
                        .foregroundColor(.white)
                        .minimumScaleFactor(0.5)
                }
                
                Spacer()
            }
            .padding()
        }
        .frame(maxWidth: .infinity)
        .frame(height: 90)
        .padding(.bottom, 10)
        .padding(.horizontal, viewModel.type == .custom ? 25 : 0)
        .padding(.top, viewModel.type == .custom ? 20 : 0)
        .onTapGesture {
            viewModel.handleButtonTap()
        }
    }
}

struct ScanLoyaltyCardButtonView_Previews: PreviewProvider {
    static var previews: some View {
        ScanLoyaltyCardButtonView(viewModel: ScanLoyaltyCardButtonViewModel(type: .custom))
    }
}
