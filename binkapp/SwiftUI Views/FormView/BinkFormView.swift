//
//  BinkFormView.swift
//  binkapp
//
//  Created by Sean Williams on 17/08/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import Combine
import SwiftUI

struct BinkFormView: View {
    enum Constants {
        static let vStackInsets = EdgeInsets(top: 20, leading: 25, bottom: 150, trailing: 25)
    }
    
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var viewModel: FormViewModel
    @ObservedObject private var themeManager = Current.themeManager
    @ObservedObject private var imageLoader = ImageLoader()
    @State var showtextFieldToolbar = false
    
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .center, vertical: .bottom), content: {
            ScrollView {
                VStack(alignment: .center, spacing: 20.0) {
                    RemoteImage(image: viewModel.brandImage ?? imageLoader.image)
                        .onAppear {
                            imageLoader.retrieveImage(for: viewModel.membershipPlan, colorScheme: colorScheme)
                            viewModel.brandImage = imageLoader.image
                        }
                        .frame(width: 70, height: 70, alignment: .center)
                        .aspectRatio(contentMode: .fit)
                    
                    if viewModel.shouldShowInfoButton {
                        Button(action: {
                            viewModel.infoButtonWasTapped()
                        }, label: {
                            Text(viewModel.infoButtonText ?? "")
                                .font(.custom(UIFont.linkTextButtonNormal.fontName, size: UIFont.linkTextButtonNormal.pointSize))
                            Image(uiImage: Asset.iconsChevronRight.image.withRenderingMode(.alwaysTemplate))
                                .resizable()
                                .frame(width: 10, height: 10, alignment: .center)
                        })
                        .foregroundColor(Color(.blueAccent))
                    }
                    
                    
                    VStack(alignment: .leading, spacing: 5, content: {
                        Text(viewModel.titleText ?? "")
                            .font(.custom(UIFont.headline.fontName, size: UIFont.headline.pointSize))
                            .fixedSize(horizontal: false, vertical: true)
                        Text(viewModel.descriptionText ?? "")
                            .font(.custom(UIFont.bodyTextLarge.fontName, size: UIFont.bodyTextLarge.pointSize))
                            .fixedSize(horizontal: false, vertical: true)
                    })
                    
                    // Textfields
                    ForEach(viewModel.datasource.fields) { field in
                        if #available(iOS 14.0, *) {
                            BinkTextfieldView(field: field, didExit: $viewModel.textfieldDidExit, presentScanner: $viewModel.presentScanner, showToolbar: $showtextFieldToolbar)
                                .accessibilityIdentifier(field.title)
                                .keyboardType(field.fieldType.keyboardType())
                        } else {
//                            BinkTextfieldView(field: field, didExit: $viewModel.textfieldDidExit)
                        }
                    }
                    
                    // Checkboxes
                    VStack(spacing: -10) {
                        ForEach(viewModel.datasource.checkboxes) { checkbox in
                            CheckboxSwiftUIVIew(checkbox: checkbox, checkedState: $viewModel.checkedState, didTapOnURL: $viewModel.didTapOnURL)
                                .padding(.horizontal, 10)
                        }
                    }
                    .frame(height: viewModel.checkboxStackHeight)
                }
                .padding(Constants.vStackInsets)
            }
            .background(Color(themeManager.color(for: .viewBackground)))
            .edgesIgnoringSafeArea(.bottom)
            .padding(.bottom, viewModel.keyboardHeight)
            .onReceive(Publishers.keyboardHeight, perform: { self.viewModel.keyboardHeight = $0 })
            
            // Keyboard Toolbar
            VStack {
                Spacer()
                if showtextFieldToolbar {
                    HStack {
                        Spacer()
                        Button(L10n.done) {
                            showtextFieldToolbar = false
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }
                        .foregroundColor(Color(.binkGradientBlueLeft))
                        .padding(.trailing, 12)
                    }
                    .frame(idealWidth: .infinity, maxWidth: .infinity, idealHeight: 44, maxHeight: 44, alignment: .center)
                    .background(Color.white)
                }
            }
        })
    }
}


// MARK: - Previews

let shouldChangeBlock: FormField.TextFieldShouldChange = { (_, _, _, _) in
    return false
}

let field1 = FormField(title: "Email", placeholder: "Enter your email bitch", validation: "", fieldType: .email, updated: { _, _ in }, shouldChange: shouldChangeBlock, fieldExited: { _ in })
let datasourceMock = FormDataSource(PaymentCardCreateModel(fullPan: nil, nameOnCard: nil, month: nil, year: nil))

struct BinkFormView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ZStack {
//                Rectangle()
//                    .foregroundColor(Color(UIColor.grey10))
//                BinkFormView(viewModel: FormViewModel(datasource: datasourceMock, title: "Title text", description: "Im a description", membershipPlan: nil, colorScheme: ColorScheme.light))
//                    .preferredColorScheme(.light)
            }
        }
    }
}

extension Publishers {
    static var keyboardHeight: AnyPublisher<CGFloat, Never> {
        let willShow = NotificationCenter.default.publisher(for: UIApplication.keyboardWillShowNotification)
            .map { $0.keyboardHeight }

        let willHide = NotificationCenter.default.publisher(for: UIApplication.keyboardWillHideNotification)
            .map { _ in CGFloat(0) }

        return MergeMany(willShow, willHide)
            .eraseToAnyPublisher()
    }
}

//#if canImport(UIKit)
//extension View {
//    func hideKeyboard() {
//        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
//    }
//}
//#endif
