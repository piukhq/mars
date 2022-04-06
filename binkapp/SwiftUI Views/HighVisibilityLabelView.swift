//
//  ContentView.swift
//  SwiftUIViews
//
//  Created by Sean Williams on 17/03/2022.
//

import SwiftUI

enum HighVisibilityLabelConstants {
    static let numberOfElementsPerRow = 8
    static let boxHeightRatio = 1.8
}

struct HighVisibilityLabelView: View {
    let text: String
    
    var membershipNumberArray: [String] {
        return text.splitStringIntoArray(elementLength: HighVisibilityLabelConstants.numberOfElementsPerRow)
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(membershipNumberArray.enumerated()), id: \.offset) { characters in
                    HighVisibilityLabelRow(membershipNumber: characters.element, row: characters.offset, parentViewWidth: geometry.size.width)
                }
            }
            .contextMenu {
                Button {
                    UIPasteboard.general.string = text
                } label: {
                    if #available(iOS 14.0, *) {
                        Label(L10n.barcodeCopyLabel, systemImage: "doc.on.doc")
                    } else {
                        Text(L10n.barcodeCopyLabel)
                    }
                }
            }
        }
    }
}

struct HighVisibilityLabelView_Previews: PreviewProvider {
    static var previews: some View {
        HighVisibilityLabelView(text: "187387098209820982")
    }
}

struct HighVisibilityLabelRow: View {
    let membershipNumber: String
    let row: Int
    let parentViewWidth: CGFloat
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            ForEach(Array(membershipNumber.enumerated()), id: \.offset) { char in
                HighVisibilityBox(digit: String(char.element), offset: char.offset, row: row, parentViewWidth: parentViewWidth)
            }
        }
    }
}

struct HighVisibilityBox: View {
    let digit: String
    let offset: Int
    let row: Int
    let parentViewWidth: CGFloat
    
    var cellWidth: CGFloat {
        return parentViewWidth / CGFloat(HighVisibilityLabelConstants.numberOfElementsPerRow)
    }
    
    var grayScale: GrayScale {
        if isEvenNumber(row) {
            return isEvenNumber(offset) ? .dark : .light
        } else {
            return isEvenNumber(offset) ? .light : .dark
        }
    }
    
    var digitCount: Int {
        return (offset + 1) + (HighVisibilityLabelConstants.numberOfElementsPerRow * row)
    }
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(grayScale.color)
                .frame(width: cellWidth, height: cellWidth * HighVisibilityLabelConstants.boxHeightRatio)
            
            VStack(spacing: 6) {
                Text(digit)
                    .font(.system(size: 40, weight: .medium, design: .default))
                    .foregroundColor(Color(Current.themeManager.color(for: .text)))
                Text(String(digitCount))
                    .font(.system(size: 10, weight: .medium, design: .default))
                    .foregroundColor(.gray)
            }
            .offset(y: 5)
        }
    }
    
    private func isEvenNumber(_ value: Int) -> Bool {
        return (value + 1) % 2 == 0
    }
}

enum GrayScale {
    case light
    case dark
    
    var color: Color {
        switch self {
        case .light:
            return .gray.opacity(0.22)
        case .dark:
            return .gray.opacity(0.43)
        }
    }
}
