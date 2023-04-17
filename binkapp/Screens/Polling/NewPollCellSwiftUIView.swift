//
//  NewPollCellSwiftUIView.swift
//  binkapp
//
//  Created by Ricardo Silva on 14/04/2023.
//  Copyright © 2023 Bink. All rights reserved.
//

import SwiftUI

struct NewPollCellSwiftUIView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.gray)
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: "chart.bar.xaxis")
                        .resizable()
                        .frame(width: 26, height: 26)
                        .foregroundColor(.white)
                        
                    Spacer()
                    Image(systemName: "xmark")
                        .resizable()
                        .frame(width: 12, height: 12)
                        .foregroundColor(.white)
                }
                .padding(.top, -8)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Which retailer would you like to see next in your Bink app?")
                        .uiFont(.calloutViewSubtitle)
                        .foregroundColor(Color.white)
                        .lineLimit(nil)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text("TAKE POLL ->")
                        .uiFont(.tabBar)
                        .foregroundColor(Color.white)
                }
                .padding(.top, -4)
            }
            .padding()
        }
        .frame(width: UIScreen.main.bounds.width - (25 * 2), height: 120)
        
        
        
//        ZStack {
//            Button(action: {
//
//            }) {
//                ZStack {
//                    RoundedRectangle(cornerRadius: 12, style: .continuous)
//                        .fill(Color.gray)
//                    VStack(alignment: .leading) {
//                        HStack {
//                            Image(systemName: "chart.bar.xaxis")
//                                .resizable()
//                                .frame(width: 26, height: 26)
//                                .foregroundColor(.white)
//
//                            Spacer()
//                            Image(systemName: "xmark")
//                                .resizable()
//                                .frame(width: 12, height: 12)
//                                .foregroundColor(.white)
//
//                        }
//                        .padding(.top, -8)
//
//                        VStack(alignment: .leading, spacing: 8) {
//                            Text("Which retailer would you like to see next in your Bink app?")
//                                .uiFont(.calloutViewSubtitle)
//                                .foregroundColor(Color.white)
//                                .lineLimit(nil)
//                                .multilineTextAlignment(.leading)
//                                .fixedSize(horizontal: false, vertical: true)
////
//                            Text("TAKE POLL ->")
//                                .uiFont(.tabBar)
//                                .foregroundColor(Color.white)
//                        }
//                        .padding(.top, -4)
//                    }
//                    .padding()
//                }
//            }
//        }
//        .frame(width: UIScreen.main.bounds.width - (25 * 2), height: 120)
    }
}

struct NewPollCellSwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        NewPollCellSwiftUIView()
    }
}
