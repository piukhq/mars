//
//  NewPollCellSwiftUIView.swift
//  binkapp
//
//  Created by Ricardo Silva on 14/04/2023.
//  Copyright © 2023 Bink. All rights reserved.
//

import SwiftUI

struct NewPollCellSwiftUIView: View {
    @ObservedObject var viewModel: NewPollCellViewModel
    
    var body: some View {
        ZStack {
            if viewModel.question != nil {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.gray)
                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: "chart.bar.xaxis")
                            .resizable()
                            .frame(width: 26, height: 26)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button(action: {
                            ///viewModel.remindLaterPressed()
                            viewModel.displayPollOptions()
                        }) {
                            Image(systemName: "xmark")
                                .resizable()
                                .frame(width: 12, height: 12)
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.top, -8)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(viewModel.question ?? "")
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
        }
        //.frame(width: viewModel.question != nil ? UIScreen.main.bounds.width - (25 * 2) : 0, height: viewModel.question != nil ? 120.0 : 0)
    }
}

struct NewPollCellSwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        NewPollCellSwiftUIView(viewModel: NewPollCellViewModel())
    }
}
