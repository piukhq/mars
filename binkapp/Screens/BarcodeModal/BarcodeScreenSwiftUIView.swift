//
//  BarcodeScreenSwiftUIView.swift
//  binkapp
//
//  Created by Sean Williams on 21/03/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import SwiftUI

struct RemoteImage: View {
    var image: Image?
    
    var body: some View {
        image?.resizable() ?? Image(Asset.binkLogo.name).resizable()
    }
}

struct BarcodeScreenSwiftUIView: View {
    @ObservedObject var viewModel: BarcodeViewModel
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack(alignment: .center) {
            ScrollView {
                VStack {
                    /// Barcode image
                    if let barcodeImage = viewModel.barcodeImage(withSize: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)) {
                        Image(uiImage: barcodeImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } else {
                        switch viewModel.imageType {
                        case .icon:
                            RemoteImage(image: viewModel.merchantImage)
                                .frame(width: 128, height: 128, alignment: .center)
                                .aspectRatio(contentMode: .fit)
                                .cornerRadius(10)
                        case .hero:
                            RemoteImage(image: viewModel.merchantImage)
                                .frame(width: 182, height: 115, alignment: .center)
                                .aspectRatio(CGSize(width: 182, height: 115), contentMode: .fit)
                                .cornerRadius(10)
                        }
                    }
                    
                    /// Description label
                    TextStackView(text: viewModel.descriptionText, font: .custom(UIFont.bodyTextLarge.fontName, size: UIFont.bodyTextLarge.pointSize))
                        .padding(.vertical, 15)
                    
                    /// Membership number
                    TextStackView(text: L10n.cardNumberTitle, font: .custom(UIFont.headline.fontName, size: 20))
                    HighVisibilityLabelView(text: viewModel.cardNumber ?? "")
                        .frame(height: heightForHighVisView(text: viewModel.cardNumber ?? ""))
                        .padding(.bottom, 15)
                    
                    /// Barcode number
                    if viewModel.shouldShowbarcodeNumber {
                        TextStackView(text: L10n.barcodeTitle, font: .custom(UIFont.headline.fontName, size: 20))
                        HighVisibilityLabelView(text: viewModel.barcodeNumber)
                            .frame(height: heightForHighVisView(text: viewModel.barcodeNumber))
                    }
                }
                .padding(.horizontal, 25)
                .padding(.top, 15)
                .onAppear {
                    viewModel.getMerchantImage(colorScheme: colorScheme)
                }
                .navigationBarTitle(viewModel.title)
            }
            .background(Color(Current.themeManager.color(for: .viewBackground)))
            
            VStack {
                Spacer()
                BinkButtonsStackView(buttons: [viewModel.reportIssueButton])
                    .padding(.bottom, 16)
            }
        }
    }
    
    struct TextStackView: View {
        let text: String
        let font: Font
        
        var body: some View {
            HStack {
                Text(text)
                    .font(font)
                Spacer()
            }
        }
    }
    
    func heightForHighVisView(text: String) -> CGFloat {
        let rowCount = splitStringIntoArray(text: text).count
        let widthOfStackView = UIScreen.main.bounds.width - 40
        let boxWidth = widthOfStackView / 8
        let boxHeight = boxWidth * 1.8
        return boxHeight * CGFloat(rowCount)
    }
    
    func splitStringIntoArray(text: String) -> [String] {
        var mutableLabelText = text
        var array: [String] = []
        
        while !mutableLabelText.isEmpty {
            let str = String(mutableLabelText.prefix(8))
            array.append(str)
            mutableLabelText = String(mutableLabelText.dropFirst(8))
        }
        
        return array
    }
}

struct BarcodeScreenSwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        BarcodeScreenSwiftUIView(viewModel: BarcodeViewModel(membershipCard: CD_MembershipCard()))
    }
}
