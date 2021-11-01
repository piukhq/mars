//
//  BarcodeView.swift
//  Bink Watch App Extension
//
//  Created by Sean Williams on 29/10/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import SwiftUI

struct BarcodeView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    let barcodeImage: UIImage
    let balance: String?
    
    var body: some View {
        VStack {
            Image(uiImage: barcodeImage)
                .resizable()
            if let balance = balance {
                Text(balance)
                    .foregroundColor(.black)
                    .font(.nunitoSemiBold(16))
            }
        }
        .padding(EdgeInsets(top: 30, leading: 10, bottom: balance != nil ? 10 : 30, trailing: 10))
        .background(Color.white)
        .edgesIgnoringSafeArea(.top)
        .edgesIgnoringSafeArea(.bottom)
        .onTapGesture {
            self.presentationMode.wrappedValue.dismiss()
        }
    }
}

struct BarcodeView_Previews: PreviewProvider {
    static var previews: some View {
        if let image = UIImage(named: "qr") {
            BarcodeView(barcodeImage: image, balance: "£10.00")
        }
    }
}
