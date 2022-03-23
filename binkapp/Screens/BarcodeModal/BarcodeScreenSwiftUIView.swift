//
//  BarcodeScreenSwiftUIView.swift
//  binkapp
//
//  Created by Sean Williams on 21/03/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import SwiftUI
import CardScan

struct RemoteImage: View {
    var image: Image?
    
    var body: some View {
        image?.resizable() ?? Image(Asset.binkLogo.name).resizable()
    }
}

struct BarcodeScreenSwiftUIView: View {
    enum Constants {
        static let largeSpace: CGFloat = 20
        static let smallSpace: CGFloat = 15
        static let cornerRadius: CGFloat = 10
        static let iconImageAspectRatio: CGFloat = 1
        static let horizontalInset: CGFloat = 25.0
        static let bottomInset: CGFloat = 150.0
        
        static let iconImageSize: CGFloat = 128
        static let heroImageWidth: CGFloat = 182
        static let heroImageHeight: CGFloat = 115
        static let titleFontSize: CGFloat = 20
    }
    
    @ObservedObject var viewModel: BarcodeViewModel
    @Environment(\.colorScheme) var colorScheme
    
    init(viewModel: BarcodeViewModel) {
        self.viewModel = viewModel
        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = Current.themeManager.color(for: .text)
    }
    
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
                                .frame(width: Constants.iconImageSize, height: Constants.iconImageSize, alignment: .center)
                                .aspectRatio(contentMode: .fit)
                                .cornerRadius(Constants.cornerRadius)
                        case .hero:
                            RemoteImage(image: viewModel.merchantImage)
                                .frame(width: Constants.heroImageWidth, height: Constants.heroImageHeight, alignment: .center)
                                .cornerRadius(Constants.cornerRadius)
                        }
                    }
                    
                    /// Description label
                    TextStackView(text: viewModel.descriptionText, font: .custom(UIFont.bodyTextLarge.fontName, size: UIFont.bodyTextLarge.pointSize))
                        .padding(.vertical, Constants.smallSpace)
                    
                    /// Membership number
                    TextStackView(text: L10n.cardNumberTitle, font: .custom(UIFont.headline.fontName, size: Constants.titleFontSize))
                    HighVisibilityLabelView(text: viewModel.cardNumber ?? "")
                        .frame(height: heightForHighVisView(text: viewModel.cardNumber ?? ""))
                        .padding(.bottom, Constants.smallSpace)
                    
                    /// Barcode number
                    if viewModel.shouldShowbarcodeNumber {
                        TextStackView(text: L10n.barcodeTitle, font: .custom(UIFont.headline.fontName, size: Constants.titleFontSize))
                        HighVisibilityLabelView(text: viewModel.barcodeNumber)
                            .frame(height: heightForHighVisView(text: viewModel.barcodeNumber))
                    }
                }
                .padding(.horizontal, Constants.horizontalInset)
                .padding(.top, Constants.smallSpace)
                .padding(.bottom, Constants.bottomInset)
                .onAppear {
                    viewModel.getMerchantImage(colorScheme: colorScheme)
                }
                .navigationBarTitle(viewModel.title)
            }
            .background(Color(Current.themeManager.color(for: .viewBackground)))
            
            VStack {
                Spacer()
                BinkButtonsStackView(buttons: [viewModel.reportIssueButton])
                    .padding(.bottom, Constants.smallSpace)
                    .actionSheet(isPresented: $viewModel.showingReportIssueOptions) {
                        ActionSheet(title: Text(""), message: Text(L10n.barcodeReportIssueTitle), buttons: [
                            .default(Text(BarcodeScreenIssue.membershipNumberIncorrect.rawValue), action: {
                                MixpanelUtility.track(.barcodeScreenIssueReported(brandName: viewModel.title, reason: .membershipNumberIncorrect))
                            }),
                            .default(Text(BarcodeScreenIssue.barcodeWontScan.rawValue), action: {
                                MixpanelUtility.track(.barcodeScreenIssueReported(brandName: viewModel.title, reason: .barcodeWontScan))
                            }),
                            .default(Text(BarcodeScreenIssue.other.rawValue), action: {
                                MixpanelUtility.track(.barcodeScreenIssueReported(brandName: viewModel.title, reason: .other))
                                ZendeskTickets().launch()
                            }),
                            .cancel()
                        ])
                    }
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
                    .foregroundColor(Color(Current.themeManager.color(for: .text)))
                Spacer()
            }
        }
    }
    
    func heightForHighVisView(text: String) -> CGFloat {
        let rowCount = splitStringIntoArray(text: text).count
        let widthOfStackView = UIScreen.main.bounds.width - (Constants.horizontalInset * 2)
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


enum BarcodeScreenIssue: String {
    case membershipNumberIncorrect = "Membership number incorrect"
    case barcodeWontScan = "Barcode won't scan"
    case other = "Other"
}
