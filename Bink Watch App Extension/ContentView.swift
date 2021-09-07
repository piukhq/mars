//
//  ContentView.swift
//  Bink Watch App Extension
//
//  Created by Nick Farrant on 03/09/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel = WatchAppViewModel()
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(viewModel.cards, id: \.id) { card in
                    NavigationLink(destination:
                                    Image(uiImage: card.barcodeImage!)
                                    .resizable()
                                    .frame(width: 100, height: 100, alignment: .center)
                    ) {
                        HStack {
                            Image(uiImage: card.iconImage!)
                                .resizable()
                                .frame(width: 40, height: 40)
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text(card.companyName)
                                if let balance = card.balanceString {
                                    Text(balance)
                                }
                            }
                        }
                    }
                }
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
