//
//  ContentView.swift
//  Bink Watch App Extension
//
//  Created by Nick Farrant on 03/09/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import SwiftUI

struct WatchContentView: View {
    enum Constants {
        static let insets = EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12)
        static let cornerRadius: CGFloat = 12
        static let imageBorderCornerRadius: CGFloat = 3
        static let imageBorderSize: CGFloat = 27
        static let imageSize: CGFloat = 25
        static let imageCornerRadius: CGFloat = 2
        static let placeholderForegroundColorAlpha: CGFloat = 0.5
        static let vStackSpacingSmall: CGFloat = 10
        static let vStackSpacingLarge: CGFloat = 15
    }
    
    @ObservedObject var viewModel = WatchAppViewModel()
    
    var body: some View {
        if viewModel.didSyncWithPhoneOnLaunch {
            if !viewModel.hasCurrentUser {
                WatchTextStack(title: L10n.unauthenticatedStateTitle, description: L10n.unauthenticatedStateDescription)
            } else if viewModel.cards.isEmpty {
                WatchTextStack(title: L10n.brandsListNoSupportedCardsTitle, description: L10n.brandsListNoSupportedCardsDescription)
            } else {
                GeometryReader { geo in
                    ScrollView {
                        VStack(spacing: geo.size.width > 190 ? Constants.vStackSpacingLarge : Constants.vStackSpacingSmall) {
                            ForEach(viewModel.cards, id: \.id) { card in
                                NavigationLink {
                                    if let barcodeImage = card.barcodeImage {
                                        BarcodeView(barcodeImage: barcodeImage, balance: card.balanceString)
                                            .navigationBarHidden(true)
                                    }
                                } label: {
                                    HStack(spacing: 10) {
                                        if let icon = card.iconImage {
                                            ZStack {
                                                RoundedRectangle(cornerRadius: Constants.imageBorderCornerRadius, style: .continuous)
                                                    .frame(width: Constants.imageBorderSize, height: Constants.imageBorderSize, alignment: .center)
                                                    .foregroundColor(.white)
                                                
                                                Image(uiImage: icon)
                                                    .resizable()
                                                    .frame(width: Constants.imageSize, height: Constants.imageSize)
                                                    .cornerRadius(Constants.imageCornerRadius)
                                            }
                                        } else {
                                            RoundedRectangle(cornerRadius: Constants.imageCornerRadius)
                                                .frame(width: Constants.imageSize, height: Constants.imageSize, alignment: .center)
                                                .foregroundColor(Color(UIColor(hexString: "#FFFFFF", alpha: Constants.placeholderForegroundColorAlpha)))
                                        }
                                        Text(card.companyName)
                                            .font(.nunitoSemiBold(16))
                                        Spacer()
                                    }
                                }
                            }
                            .frame(height: 40)
                        }
                        .padding(.top, 10)
                        .padding(.bottom, 20)
                    }
                    .edgesIgnoringSafeArea(.bottom)
                }
            }
        } else {
            if viewModel.noResponseFromPhone {
                WatchTextStack(title: L10n.noResponseTitle, description: L10n.noResponseDesciption)
            } else {
                ProgressView()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 20) {
                            viewModel.noResponseFromPhone = true
                        }
                    }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        WatchContentView()
    }
}
