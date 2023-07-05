//
//  WalletCardView.swift
//  BinkWidgetExtension
//
//  Created by Sean Williams on 01/07/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import SwiftUI
import WidgetKit

struct WalletCardView: View {
    let membershipCard: MembershipCardWidget
    
    var backgroundColorIsLight: Bool {
        let backgroundColor = UIColor(hexString: membershipCard.backgroundColor ?? "")
        return backgroundColor.isLight(threshold: 0.7)
    }
    
    enum Constants {
        static let insets = EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12)
        static let cornerRadius: CGFloat = 12
        static let imageBorderCornerRadius: CGFloat = 6
        static let imageBorderSize: CGFloat = 39
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
        Link(destination: membershipCard.quickLaunchUrl) {
            HStack(alignment: .center, spacing: 0) {
                if let imageData = membershipCard.imageData, let uiImage = UIImage(data: imageData) {
                    ZStack {
                        RoundedRectangle(cornerRadius: Constants.imageBorderCornerRadius, style: .continuous)
                            .frame(width: Constants.imageBorderSize, height: Constants.imageBorderSize, alignment: .center)
                            .foregroundColor(.white)
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: Constants.imageSize, height: Constants.imageSize)
                            .clipShape(RoundedRectangle(cornerRadius: Constants.imageCornerRadius, style: .continuous))
                    }

                    Text(membershipCard.planName ?? "")
                        .padding(.leading, Constants.textLeadingPadding)
                        .padding(.trailing, Constants.textTrailingPadding)
                        .lineLimit(Constants.textLineLimit)
                        .foregroundColor(backgroundColorIsLight ? .black : .white)
                        .font(.nunitoBold(12))
                    Spacer()
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

struct WalletCardView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            WalletCardView(membershipCard: MembershipCardWidget(id: "1", imageData: UIImage(named: "iceland")?.pngData(), barCodeImage: UIImage(named: "iceland")?.pngData(), backgroundColor: "#0000FF", planName: "Tesco"))
        }
        .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
