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
    @State private var submitted = false
    var body: some View {
        VStack(alignment: .leading) {
            if viewModel.pollData != nil {
                Text("THIS POLL EXPIRES IN " + viewModel.daysToEnd() + " DAYS")
                    .uiFont(.tabBar)
                    .multilineTextAlignment(.leading)
                    .padding()
                    .padding(.bottom, 8)
                
                Text(viewModel.pollData?.question ?? "")
                    .uiFont(.headline)
                    .lineLimit(nil)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding()
                
                GeometryReader { gp in
                    ScrollView {
                        VStack(spacing: 10) {
                            ForEach(viewModel.pollData?.answers ?? [], id: \.self) { answer in
                                Button(action: {
                                    viewModel.setCurrentAnswer(answer: answer)
                                }) {
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .fill(viewModel.gotVotes ? Color(UIColor.lightGray) : viewModel.currentAnswer == answer ? Color(UIColor.darkGray) : Color(UIColor.lightGray))
                                            .frame(maxWidth: gp.size.width)
                                            .frame(height: 60)
                                        
                                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                .fill(Color(UIColor.darkGray))
                                                .frame(maxWidth: viewModel.gotVotes ? gp.size.width * viewModel.votePercentage(answer: answer) : 0, alignment: .leading)
                                                .frame(height: 60, alignment: .leading)
                                                .animation(.easeIn(duration: 2), value: viewModel.gotVotes)
                                        
                                        HStack {
                                            ZStack {
                                                Image(systemName: "circle")
                                                    .resizable()
                                                    .frame(width: 16, height: 16)
                                                    .foregroundColor(.black)
                                                
                                                if answer == viewModel.currentAnswer {
                                                    Image(systemName: "circle.fill")
                                                        .resizable()
                                                        .frame(width: 12, height: 12)
                                                        .foregroundColor(.black)
                                                }
                                            }
                                            
                                            Text(answer)
                                                .uiFont(.checkboxText)
                                            
                                            Spacer()
                                            if viewModel.gotVotes {
                                                Text("\(Int(viewModel.votePercentage(answer: answer) * 100))" + "%")
                                                    .uiFont(.tabBar)
                                            }
                                        }
                                        .padding()
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                }
                
                Button(action: {
                    viewModel.submitAnswer()
                    submitted = true
                }) {
                    ZStack(alignment: .center) {
                        RoundedRectangle(cornerRadius: 25, style: .continuous)
                            .fill(.gray)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                        
                        Text("SUBMIT")
                            .uiFont(.headline)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                .disabled(viewModel.currentAnswer == nil || submitted)
                .padding()
            }
            /*
            if viewModel.pollData != nil {
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
                                    viewModel.setAnswer(answer: answer)
                                }) {
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .fill(.white)
                                            .frame(maxWidth: gp.size.width)
                                            .frame(height: 60)
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .fill(.blue)
                                            .frame(maxWidth: drawingWidth ? gp.size.width * viewModel.votePercentage(answer: answer) : 0, alignment: .leading)
                                            .frame(height: 60, alignment: .leading)
                                            .animation(.easeInOut(duration: 2), value: drawingWidth)
                                        
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
            } else {
                Text("nothing to show")
            }
            */
        }
        .background(Color(Current.themeManager.color(for: .viewBackground)))
    }
}

struct PollSwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        PollSwiftUIView(viewModel: PollSwiftUIViewModel())
    }
}
