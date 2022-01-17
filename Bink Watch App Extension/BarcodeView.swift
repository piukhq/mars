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
    let viewModel: WatchAppViewModel
    
    var body: some View {
        HStack {
            Spacer()
            VStack {
                Spacer()
                Image(uiImage: barcodeImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                if let balance = balance {
                    Text(balance)
                        .foregroundColor(.black)
                        .font(.nunitoSemiBold(16))
                } else {
                    Spacer()
                }
            }
            Spacer()
        }
        .background(Color.white)
        .edgesIgnoringSafeArea([.top, .bottom])
        .onTapGesture {
            self.presentationMode.wrappedValue.dismiss()
        }
        .onAppear(perform: {
            viewModel.viewingBarcode = true
        })
        .onDisappear {
            viewModel.viewingBarcode = false
            viewModel.refreshWallet()
        }
    }
}

struct BarcodeView_Previews: PreviewProvider {
    static var previews: some View {
        if let image = UIImage(named: "qr") {
            BarcodeView(barcodeImage: image, balance: "£10.00", viewModel: WatchAppViewModel())
        }
    }
}
