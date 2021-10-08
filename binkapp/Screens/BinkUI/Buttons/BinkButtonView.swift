//
//  BinkButtonView.swift
//  binkapp
//
//  Created by Sean Williams on 07/09/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import SwiftUI

class ButtonViewModel: ObservableObject {
    @Published var datasource: FormDataSource
    @Published var isLoading = false
    
    init(datasource: FormDataSource) {
        self.datasource = datasource
    }
}

struct BinkButtonView: View, Identifiable {
    @ObservedObject var viewModel: ButtonViewModel
    @State var enabled = false
    @State var loading = false
    
    enum ButtonType {
        case gradient
        case plain
    }

    var id = UUID()
    var title: String
    var buttonTapped: () -> Void
    var type: ButtonType
    var alwaysEnabled = false
    
    var textColor: Color {
        return type == .gradient ? .white : Color(Current.themeManager.color(for: .text))
    }
    
    var body: some View {
        Button {
            loading = type == .gradient ? true : false
            buttonTapped()
        } label: {
            Text(loading ? "" : title)
                .frame(width: UIScreen.main.bounds.width * 0.75, height: 52.0)
                .background(
                    ZStack {
                        Color(Current.themeManager.color(for: .viewBackground))
                        if type == .gradient {
                            LinearGradient(gradient: Gradient(colors: [Color(.binkGradientBlueRight), Color(.binkGradientBlueLeft)]), startPoint: .leading, endPoint: .trailing)
                                .opacity(enabled ? 1.0 : 0.5)
                        }
                    })
                .cornerRadius(52 / 2)
                .foregroundColor(enabled ? textColor : .white.opacity(0.5))
                .font(.custom(UIFont.buttonText.fontName, size: UIFont.buttonText.pointSize))
                .shadow(color: .black.opacity(type == .gradient ? 0.2 : 0.0), radius: 10, x: 3.0, y: 8.0)
                .overlay(ActivityIndicator(animate: $loading, style: .medium), alignment: .center)
        }
        .disabled(!enabled)
        .onReceive(viewModel.datasource.$fullFormIsValid) { isValid in
            enabled = alwaysEnabled
            guard !alwaysEnabled else { return }
            enabled = isValid
        }
        .onReceive(viewModel.$isLoading) { isLoading in
            self.loading = isLoading
        }
        .accessibility(identifier: title)
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
    var buttons: [BinkButtonView]
    
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
//                    BinkButtonView(datasource: FormDataSource(accessForm: .success), isLoading: false, title: "Bello", buttonTapped: {}, type: .gradient),
//                    BinkButtonView(datasource: FormDataSource(accessForm: .addEmail), enabled: true, title: "Continue", buttonTapped: {}, type: .plain)
//                ])
//            }
//        }
//    }
//}
