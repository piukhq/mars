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
    @State private var drawingWidth = false
    var body: some View {
        VStack {
            Text(viewModel.pollData?.title ?? "")
            ZStack {
                Text(viewModel.pollData?.question ?? "")
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .background(.teal)
            
            GeometryReader { gp in
                ScrollView {
                    VStack {
                        ForEach(viewModel.pollData?.answers ?? [], id: \.self) { answer in
                            Button(action: {
                                // What to do
                            }) {
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(.white)
                                        .frame(maxWidth: gp.size.width)
                                        .frame(height: 60)
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(.blue)
                                        .frame(maxWidth: drawingWidth ? gp.size.width * 1.0 : 0, alignment: .leading)
                                        .frame(height: 60, alignment: .leading)
                                        .animation(.easeInOut(duration: 2).repeatForever(autoreverses: false), value: drawingWidth)
                                    
                                    Text(answer)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                }
                                .padding(.top, 20)
                            }
                        }
                    }
                    .padding()
                    .onAppear {
                        drawingWidth.toggle()
                    }
                }
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
