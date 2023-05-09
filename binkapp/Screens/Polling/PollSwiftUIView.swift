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
    @ObservedObject var themeManager = Current.themeManager
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if !viewModel.submitted {
                Text(L10n.expiresIn + countdownText)
                    .uiFont(.pollTimer)
                    .foregroundColor(Color(.binkBlue))
                    .multilineTextAlignment(.leading)
                    .onReceive(timer) { _ in
                        countdownText = viewModel.getTimeToEnd()
                        if countdownText.isEmpty {
                            self.timer.upstream.connect().cancel()
                        }
                    }
                
                Text(viewModel.pollData?.question ?? "")
                    .uiFont(.pollAnswer)
                    .foregroundColor(Color(themeManager.color(for: .text)))
                    .lineLimit(nil)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                Text(L10n.pollAnswerThankYou)
                    .uiFont(.pollAnswer)
                    .foregroundColor(Color(themeManager.color(for: .text)))
                    .lineLimit(nil)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text(viewModel.pollData?.question ?? "")
                    .uiFont(.pollTimer)
                    .foregroundColor(Color(.binkBlue))
                    .lineLimit(nil)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding()
        .padding(.bottom, -20)
    }
}

struct PollSwiftUIView: View {
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject var viewModel: PollSwiftUIViewModel
    @ObservedObject var themeManager = Current.themeManager
    @State private var countdownText = ""
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                if viewModel.pollData != nil {
                    PollTopTextView(viewModel: viewModel)
                    
                    VStack(spacing: 10) {
                        ForEach(viewModel.pollData?.answers ?? [], id: \.self) { answer in
                            Button(action: {
                                if !viewModel.submitted {
                                    viewModel.currentAnswer = answer
                                }
                            }) {
                                VStack(alignment: .leading) {
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .fill(viewModel.gotVotes ? viewModel.colorForUnansweredRow(colorScheme: colorScheme) : viewModel.currentAnswer == answer ? viewModel.colorForAnsweredRow(colorScheme: colorScheme) : viewModel.colorForUnansweredRow(colorScheme: colorScheme))
                                            .frame(maxWidth: .infinity)
                                            .frame(height: 73)
                                        GeometryReader { gp in
                                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                .fill(viewModel.colorForAnsweredRow(colorScheme: colorScheme))
                                                .frame(maxWidth: viewModel.gotVotes ? gp.size.width * viewModel.votePercentage(answer: answer) : 0, alignment: .leading)
                                                .frame(height: 73, alignment: .leading)
                                                .animation(.easeIn(duration: viewModel.gotVotes ? 2 : 0), value: viewModel.gotVotes)
                                        }
                                        
                                        HStack {
                                            ZStack {
                                                Image(systemName: "circle")
                                                    .resizable()
                                                    .frame(width: 15, height: 15)
                                                    .foregroundColor(answer == viewModel.currentAnswer ? .white : viewModel.colorForOuterCircleIcons(colorScheme: colorScheme))
                                                
                                                if answer == viewModel.currentAnswer {
                                                    Image(systemName: "circle.fill")
                                                        .resizable()
                                                        .frame(width: 11, height: 11)
                                                        .foregroundColor(.white)
                                                }
                                            }
                                            
                                            Text(answer)
                                                .uiFont(.pollOption)
                                                .foregroundColor(Color(themeManager.color(for: .text)))
                                            
                                            Spacer()
                                            if viewModel.gotVotes {
                                                Text("\(Int(viewModel.votePercentage(answer: answer) * 100))" + "%")
                                                    .uiFont(.tabBar)
                                                    .foregroundColor(Color(themeManager.color(for: .text)))
                                            }
                                        }
                                        .padding()
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                    
                    if viewModel.currentAnswer == nil {
                        BinkButtonsStackView(buttons: [viewModel.disabledAnswerButton])
                            .padding(.top, -23)
                    } else if viewModel.currentAnswer != nil && !viewModel.submitted {
                        BinkButtonsStackView(buttons: [viewModel.submitAnswerButton])
                            .padding(.top, -23)
                    } else if viewModel.submitted {
                        BinkButtonsStackView(buttons: [viewModel.editVoteButton, viewModel.doneButton])
                            .padding(.top, -46)
                    }
                }
            }
            .background(Color(Current.themeManager.color(for: .viewBackground)))
        }
        .background(Color(Current.themeManager.color(for: .viewBackground)))
    }
}

struct PollSwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        PollSwiftUIView(viewModel: PollSwiftUIViewModel())
    }
}
