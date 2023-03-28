//
//  PollSwiftUIView.swift
//  binkapp
//
//  Created by Ricardo Silva on 28/03/2023.
//  Copyright © 2023 Bink. All rights reserved.
//

import SwiftUI

struct PollSwiftUIView: View {
    @ObservedObject var viewModel: PollSwiftUIViewModel
    
    var body: some View {
        VStack {
            Text(viewModel.pollData?.title ?? "")
            ZStack {
                Text(viewModel.pollData?.question ?? "")
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .background(.teal)
            
            ScrollView {
                VStack {
                    GeometryReader { gp in
                        
                    }
                    ForEach(viewModel.pollData?.answers ?? [], id: \.self) { answer in
                        Button(action: {
                            // What to do
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(.white)
                                    //.frame(maxWidth: .infinity)
                                    .frame(height: 60)
//                                RoundedRectangle(cornerRadius: 12, style: .continuous)
//                                    .fill(.blue)
//                                    .frame(maxWidth: .infinity)
//                                    .frame(height: 60)
//                                    .animation(.easeInOut(duration: 10).repeatForever(autoreverses: false), value: drawingWidth)
                                
                                Text(answer)
                            }
                            .padding(.top, 20)
                        }
                    }
                }
                .padding()
            }
            
            VStack(spacing: 6) {
                Text("Time left to vote:")
                Text(viewModel.daysToEnd() + " Days")
            }
            .padding(.bottom, 20)
        }
        .background(Color(Current.themeManager.color(for: .viewBackground)))
    }
}

struct PollSwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        PollSwiftUIView(viewModel: PollSwiftUIViewModel())
    }
}
