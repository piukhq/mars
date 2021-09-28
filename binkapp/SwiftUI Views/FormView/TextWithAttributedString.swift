//
//  TextWithAttributedString.swift
//  binkapp
//
//  Created by Sean Williams on 27/09/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import SwiftUI

struct TextWithAttributedString: View {
    var attributedText: NSAttributedString
    @Binding var url: URL?
    @State private var height: CGFloat = .zero
    
    var body: some View {
        InternalTextView(attributedText: attributedText, dynamicHeight: $height, url: $url)
            .frame(minHeight: height)
    }
}

struct InternalTextView: UIViewRepresentable {
    var attributedText: NSAttributedString
    @Binding var dynamicHeight: CGFloat
    @Binding var url: URL?
    
    func makeCoordinator() -> Coordinator {
        Coordinator($url)
    }
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        textView.textAlignment = .justified
        textView.isScrollEnabled = false
        textView.isUserInteractionEnabled = true
        textView.showsVerticalScrollIndicator = false
        textView.showsHorizontalScrollIndicator = false
        textView.allowsEditingTextAttributes = false
        textView.backgroundColor = .clear
        textView.tintColor = .clear
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        textView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        textView.linkTextAttributes = [.foregroundColor: UIColor.blueAccent, .underlineStyle: NSUnderlineStyle.single.rawValue]
        textView.delegate = context.coordinator
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.attributedText = attributedText
        DispatchQueue.main.async {
            dynamicHeight = uiView.sizeThatFits(CGSize(width: uiView.bounds.width, height: CGFloat.greatestFiniteMagnitude)).height
        }
    }
}

extension InternalTextView {
    class Coordinator: NSObject, UITextViewDelegate {
        @Binding private var url: URL?
        
        init(_ url: Binding<URL?>) {
            _url = url
        }
        
        func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
            self.url = URL
            return false
        }
    }
}

//struct TextWithAttributedString_Previews: PreviewProvider {
//    static var previews: some View {
//        TextWithAttributedString()
//    }
//}
