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
                .foregroundColor(enabled ? textColor : .white.opacity(0.5))
                .font(.custom(UIFont.buttonText.fontName, size: UIFont.buttonText.pointSize))
                Spacer()
            }
        }
        .frame(width: UIScreen.main.bounds.width * 0.75, height: 52.0)
        .disabled(!enabled)
        .background(
            ZStack {
                Color(Current.themeManager.color(for: .viewBackground))
                if type == .gradient {
                    LinearGradient(gradient: Gradient(colors: [Color(.binkGradientBlueRight), Color(.binkGradientBlueLeft)]), startPoint: .leading, endPoint: .trailing)
                        .opacity(enabled ? 1.0 : 0.5)
                }
            })
        .cornerRadius(52 / 2)
        .shadow(color: .black.opacity(type == .gradient ? 0.2 : 0.0), radius: 10, x: 3.0, y: 8.0)
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

struct BinkButtonsStackView: View {
    enum Constants {
        static let buttonHeight: CGFloat = 52.0
        static let buttonSpacing: CGFloat = 25.0
        static let height: CGFloat = buttonHeight + buttonSpacing
    }
    
    @Environment(\.colorScheme) private var colorScheme
    var buttons: [BinkButtonSwiftUIView]
    
    var body: some View {
        VStack {
            Spacer()
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color(Current.themeManager.color(for: .viewBackground)), dynamicMaskGradientClearColor]), startPoint: .bottom, endPoint: .top)
                    .padding(.top, 20)
                
                VStack(alignment: .center, spacing: Constants.buttonSpacing) {
                    Spacer(minLength: Constants.buttonSpacing)
                    ForEach(buttons) { button in
                        button
                    }
                    Spacer(minLength: BinkButtonsView.bottomSafePadding)
                }
            }
            .frame(width: UIScreen.main.bounds.width, height: BinkButtonsView.bottomSafePadding + (Constants.height * CGFloat(buttons.count)), alignment: .center)
            
            if #available(iOS 14.0, *) {} else {
                /// Required for iOS 13
                Spacer()
                    .frame(height: UIApplication.bottomSafeArea)
            }
        }
        .background(Color.clear)
        .edgesIgnoringSafeArea(.bottom)
        .offset(y: BinkButtonsView.bottomSafePadding - BinkButtonsView.bottomPadding)
    }
    
    private var dynamicMaskGradientClearColor: Color {
        switch Current.themeManager.currentTheme.type {
        case .system:
            switch colorScheme {
            case .light:
                return .white.opacity(0.01)
            case .dark:
                return .clear
            @unknown default:
                return .white.opacity(0.01)
        }
        case .light:
            return .white.opacity(0.01)
        case .dark:
            return .clear
        }
    }
}

//struct BinkButtonStackView_Previews: PreviewProvider {
//    static var previews: some View {
//        Group {
//            ZStack {
//                Rectangle()
//                    .foregroundColor(Color(UIColor.grey10))
//                BinkButtonsStackView(buttons: [
//                    BinkButtonSwiftUIView(viewModel: ButtonViewModel(datasource: FormDataSource(accessForm: .magicLink), title: "Continue"), loading: false, buttonTapped: {}, type: .gradient, alwaysEnabled: true),
//                    BinkButtonSwiftUIView(viewModel: ButtonViewModel(datasource: FormDataSource(accessForm: .addEmail), title: "Continue"), buttonTapped: {}, type: .plain)
//                ])
//            }
//        }
//    }
//}
