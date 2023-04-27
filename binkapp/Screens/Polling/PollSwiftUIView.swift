//
//  PollSwiftUIView.swift
//  binkapp
//
//  Created by Ricardo Silva on 28/03/2023.
//  Copyright © 2023 Bink. All rights reserved.
//

import SwiftUI

struct PollTopTextView: View {
    var viewModel: PollSwiftUIViewModel
    @State private var countdownText = ""
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        if !viewModel.submitted {
            Text(L10n.expiresIn + countdownText)
                .uiFont(.tabBar)
                .foregroundColor(Color(.binkBlue))
                .multilineTextAlignment(.leading)
                .padding()
                .padding(.bottom, 8)
                .onReceive(timer) { _ in
                    countdownText = viewModel.getTimeToEnd()
                    if countdownText.isEmpty {
                        self.timer.upstream.connect().cancel()
                    }
                }
            
            Text(viewModel.pollData?.question ?? "")
                .uiFont(.headline)
                .lineLimit(nil)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .padding()
        } else {
            Text(L10n.pollAnswerThankYou)
                .uiFont(.headline)
                .lineLimit(nil)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .padding()
                .padding(.top, 20)
            
            Text(viewModel.pollData?.question ?? "")
                .uiFont(.walletPromptTitleSmall)
                .foregroundColor(Color(.binkBlue))
                .lineLimit(nil)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .padding()
                .padding(.bottom, -20)
        }
    }
}

struct PollSwiftUIView: View {
    @ObservedObject var viewModel: PollSwiftUIViewModel
    @State var countdownText = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            if viewModel.pollData != nil {
                PollTopTextView(viewModel: viewModel)
                
                GeometryReader { gp in
                    ScrollView {
                        VStack(spacing: 10) {
                            ForEach(viewModel.pollData?.answers ?? [], id: \.self) { answer in
                                Button(action: {
                                    if !viewModel.submitted {
                                        viewModel.setCurrentAnswer(answer: answer)
                                    }
                                }) {
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .fill(viewModel.gotVotes ? Color(.unansweredRowGreen) : viewModel.currentAnswer == answer ? Color(.answeredRowGreen) : Color(.unansweredRowGreen))
                                            .frame(maxWidth: gp.size.width)
                                            .frame(height: 60)
                                        
                                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .fill(Color(.percentageGreen))
                                                .frame(maxWidth: viewModel.gotVotes ? gp.size.width * viewModel.votePercentage(answer: answer) : 0, alignment: .leading)
                                                .frame(height: 60, alignment: .leading)
                                                .animation(.easeIn(duration: viewModel.gotVotes ? 2 : 0), value: viewModel.gotVotes)
                                        
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

                if viewModel.currentAnswer == nil {
                    BinkButtonsStackView(buttons: [viewModel.disabledAnswerButton])
                } else if viewModel.currentAnswer != nil && !viewModel.submitted {
                    BinkButtonsStackView(buttons: [viewModel.submitAnswerButton])
                } else if viewModel.submitted {
                    BinkButtonsStackView(buttons: [viewModel.editVoteButton, viewModel.doneButton])
                        .padding(.top, -40)
                }
            }
        }
        .background(Color(Current.themeManager.color(for: .viewBackground)))
    }
}

struct PollSwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        PollSwiftUIView(viewModel: PollSwiftUIViewModel())
    }
}
