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
                    NavigationLink(destination: Text(card.companyName)) {
                        HStack {
                            Image(uiImage: card.iconImage!)
                                .resizable()
                                .frame(width: 40, height: 40)
                            Spacer()
                            Text(card.companyName)
                        }
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
