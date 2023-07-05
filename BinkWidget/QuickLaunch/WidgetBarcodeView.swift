//
//  WidgetBarcodeView.swift
//  BinkWidgetExtension
//
//  Created by Ricardo Silva on 04/07/2023.
//  Copyright © 2023 Bink. All rights reserved.
//

import SwiftUI
import WidgetKit

struct WidgetBarcodeView: View {
    let membershipCard: MembershipCardWidget
    
    var backgroundColorIsLight: Bool {
        let backgroundColor = UIColor(hexString: membershipCard.backgroundColor ?? "")
        return backgroundColor.isLight(threshold: 0.7)
    }
    
    enum Constants {
        static let insets = EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12)
        static let cornerRadius: CGFloat = 12
        static let imageBorderCornerRadius: CGFloat = 6
        static let imageBorderSize: CGFloat = 170
        static let imageSize: CGFloat = 36
        static let imageCornerRadius: CGFloat = 5
        static let placeholderImageCornerRadius: CGFloat = 5
        static let placeholderForegroundColorAlpha: CGFloat = 0.5
        static let shadowWhiteLevel: Double = 2
        static let shadowOpacity: Double = 0.5
        static let shadowRadius: CGFloat = 2
        static let shadowOffset: CGFloat = 1.0
        static let textLeadingPadding: CGFloat = 10
        static let textTrailingPadding: CGFloat = -5
        static let textLineLimit: Int = 2
    }
    
    var body: some View {
        Link(destination: membershipCard.barcodeLaunchUrl) {
            HStack {
                if let imageData = membershipCard.imageData, let uiImage = UIImage(data: imageData) {
                    ZStack {
                        RoundedRectangle(cornerRadius: Constants.imageBorderCornerRadius, style: .continuous)
                            .frame(width: 364, height: 170, alignment: .center)
                            .foregroundColor(Color("binkBlue"))
                        HStack(alignment: .center, spacing: 40) {
                            VStack {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: Constants.imageSize, height: Constants.imageSize)
                                    .clipShape(RoundedRectangle(cornerRadius: Constants.imageCornerRadius, style: .continuous))
                                    //.padding(.leading, Constants.textLeadingPadding)
                                
                                Text(membershipCard.planName ?? "")
                                    //.padding(.leading, Constants.textLeadingPadding)
                                    .lineLimit(Constants.textLineLimit)
                                    .multilineTextAlignment(.leading)
                                    .foregroundColor(.white)
                                    .font(.nunitoBold(12))
                            }
                            .padding()
                            
                            if let barcodeData = membershipCard.barCodeImage, let uiImage = UIImage(data: barcodeData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 182, height: 128)
                                    .clipShape(RoundedRectangle(cornerRadius: Constants.imageCornerRadius, style: .continuous))
                                    .padding(.trailing, 20)
                            }
                        }
                    }
//                    HStack {
//                        if let barcodeData = membershipCard.barCodeImage, let uiImage = UIImage(data: barcodeData) {
//                            Spacer()
//                            Image(uiImage: uiImage)
//                                .resizable()
//                                .aspectRatio(contentMode: .fit)
//                                .frame(width: Constants.imageSize, height: Constants.imageSize)
//                                .clipShape(RoundedRectangle(cornerRadius: Constants.imageCornerRadius, style: .continuous))
//                        }
//                    }
                } else {
                    RoundedRectangle(cornerRadius: Constants.placeholderImageCornerRadius)
                        .frame(width: Constants.imageSize, height: Constants.imageSize, alignment: .center)
                        .foregroundColor(Color(UIColor(hexString: "#FFFFFF", alpha: Constants.placeholderForegroundColorAlpha)))
                    
                    Text(membershipCard.planName ?? "")
                        .padding(.leading, Constants.textLeadingPadding)
                        .padding(.trailing, Constants.textTrailingPadding)
                        .lineLimit(Constants.textLineLimit)
                        .foregroundColor(backgroundColorIsLight ? .black : .white)
                        .font(.nunitoBold(12))
                    Spacer()
                }
            }
            .padding(Constants.insets)
            .background(
                RoundedRectangle(cornerRadius: Constants.cornerRadius, style: .continuous)
                    .foregroundColor(Color(UIColor(hexString: membershipCard.backgroundColor ?? "#009190")))
            )
        }
    }
}

struct WidgetBarcodeView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            WidgetBarcodeView(membershipCard: MembershipCardWidget(id: "1", imageData: UIImage(named: "iceland")?.pngData(), barCodeImage: UIImage(named: "iceland")?.pngData(), backgroundColor: "#0000FF", planName: "Tesco"))
        }
        .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
