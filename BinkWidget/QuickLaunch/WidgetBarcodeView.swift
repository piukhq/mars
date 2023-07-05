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
    
    enum Constants {
        static let insets = EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12)
        static let imageSize: CGFloat = 120
        static let imageCornerRadius: CGFloat = 5
        static let textLineLimit: Int = 2
    }
    
    var body: some View {
        Link(destination: membershipCard.barcodeLaunchUrl) {
            VStack(alignment: .leading, spacing: 4) {
                if let barcodeData = membershipCard.barCodeImage, let uiImage = UIImage(data: barcodeData) {
                    
                    Text(membershipCard.planName ?? "")
                        //.padding(.leading, Constants.textLeadingPadding)
                        .lineLimit(Constants.textLineLimit)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(.white)
                        .font(.nunitoBold(12))
                    
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity)
                        .frame(height: Constants.imageSize)
                        .clipShape(RoundedRectangle(cornerRadius: Constants.imageCornerRadius, style: .continuous))
                } else {
                    Text(membershipCard.planName ?? "")
                        .lineLimit(Constants.textLineLimit)
                        .foregroundColor(.white)
                        .font(.nunitoBold(12))
                }
            }
            .background(Color("binkBlue"))
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
