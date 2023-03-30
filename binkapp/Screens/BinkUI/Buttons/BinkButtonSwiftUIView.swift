//
//  BinkButtonView.swift
//  binkapp
//
//  Created by Sean Williams on 07/09/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import SwiftUI

class ButtonViewModel: ObservableObject {
    @Published var isLoading = false
    
    var title: String

    init(title: String) {
        self.title = title
    }
}

struct BinkButtonSwiftUIView: View, Identifiable {
    enum Constants {
        static let halfOpacity: CGFloat = 0.5
        static let fullOpacity: CGFloat = 1
        static let aspectRatioMultiplier: CGFloat = 0.75
        static let height: CGFloat = 52
        static let cornerRadius: CGFloat = 52 / 2
        static let shadowSemiOpaque: CGFloat = 0.2
        static let shadowTransparent: CGFloat = 0
        static let shadowRadius: CGFloat = 10
        static let shadowXPosition: CGFloat = 3.0
        static let shadowYPosition: CGFloat = 8.0
    }
    
    @ObservedObject var viewModel: ButtonViewModel
    @State var enabled = false
    @State var loading = false
    
    enum ButtonType {
        case gradient
        case plain
    }

    var id = UUID()
    var alwaysEnabled = false
    var buttonTapped: () -> Void
    var type: ButtonType
    
    var textColor: Color {
        return type == .gradient ? .white : Color(Current.themeManager.color(for: .text))
    }
    
    var body: some View {
        Button {
            buttonTapped()
            loading = type == .gradient ? true : false
        } label: {
            HStack {
                Spacer()
            Text(loading ? "" : viewModel.title)
                .foregroundColor(enabled ? textColor : .white.opacity(Constants.halfOpacity))
                .font(.custom(UIFont.buttonText.fontName, size: UIFont.buttonText.pointSize))
                Spacer()
            }
            .frame(width: UIScreen.main.bounds.width * Constants.aspectRatioMultiplier, height: Constants.height)
        }
        .disabled(!enabled)
        .background(
            ZStack {
                if type == .gradient {
                    Color(uiColor: .binkBlue)
                        .opacity(enabled ? Constants.fullOpacity : Constants.halfOpacity)
                } else {
                    Color(.clear)
                }
            })
        .cornerRadius(Constants.cornerRadius)
        .shadow(color: .black.opacity(type == .gradient ? Constants.shadowSemiOpaque : Constants.shadowTransparent), radius: Constants.shadowRadius, x: Constants.shadowXPosition, y: Constants.shadowYPosition)
        .overlay(ActivityIndicator(animate: $loading, style: .medium), alignment: .center)
        .onReceive(viewModel.$isLoading) { isLoading in
            self.loading = isLoading
        }
        .accessibility(identifier: viewModel.title)
    }
}

struct ActivityIndicator: UIViewRepresentable {
    @Binding var animate: Bool
    let style: UIActivityIndicatorView.Style

    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.color = .white
        return activityIndicator
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        animate ? uiView.startAnimating() : uiView.stopAnimating()
    }
}


class BinkButtonsStackViewModel {
    enum Constants {
        static let gradientOpacity: CGFloat = 0
    }
    
    func dynamicMaskGradientClearColor(colorScheme: ColorScheme) -> Color {
        switch Current.themeManager.currentTheme.type {
        case .system:
            switch colorScheme {
            case .light:
                return .white.opacity(Constants.gradientOpacity)
            case .dark:
                return .clear
            @unknown default:
                return .white.opacity(Constants.gradientOpacity)
        }
        case .light:
            return .white.opacity(Constants.gradientOpacity)
        case .dark:
            return .clear
        }
    }
}

struct BinkButtonsStackView: View {
    enum Constants {
        static let buttonSpacing: CGFloat = 25.0
        static let height: CGFloat = BinkButtonSwiftUIView.Constants.height + buttonSpacing
        static let topPadding: CGFloat = 20
        static let gradientOpacity: CGFloat = 0.1
    }
    
    @Environment(\.colorScheme) private var colorScheme
    var buttons: [BinkButtonSwiftUIView]
    let viewModel = BinkButtonsStackViewModel()
    
    var body: some View {
        VStack {
            Spacer()
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color(Current.themeManager.color(for: .viewBackground)), viewModel.dynamicMaskGradientClearColor(colorScheme: colorScheme)]), startPoint: .bottom, endPoint: .top)
                    .padding(.top, Constants.topPadding)
                
                VStack(alignment: .center, spacing: Constants.buttonSpacing) {
                    Spacer(minLength: Constants.buttonSpacing)
                    ForEach(buttons) { button in
                        button
                    }
                    Spacer(minLength: BinkButtonsView.bottomSafePadding)
                }
            }
            .frame(width: UIScreen.main.bounds.width, height: BinkButtonsView.bottomSafePadding + (Constants.height * CGFloat(buttons.count)), alignment: .center)
        }
        .background(Color.clear)
        .edgesIgnoringSafeArea(.bottom)
        .offset(y: BinkButtonsView.bottomSafePadding - BinkButtonsView.bottomPadding)
    }
}

struct BinkButtonStackView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ZStack {
                Rectangle()
                    .foregroundColor(Color(UIColor.grey10))
                BinkButtonsStackView(buttons: [
                    BinkButtonSwiftUIView(viewModel: ButtonViewModel(title: "Continue"), buttonTapped: {}, type: .gradient)
                ])
            }
        }
    }
}
