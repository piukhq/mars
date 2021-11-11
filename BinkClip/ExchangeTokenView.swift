//
//  ExchangeTokenView.swift
//  BinkClip
//
//  Created by Sean Williams on 11/11/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import SwiftUI

struct ExchangeTokenView: View {
    @State var token = ""
    var body: some View {
        Text("Exchanging Token: \(token)")
    }
}

struct ExchangeTokenView_Previews: PreviewProvider {
    static var previews: some View {
        ExchangeTokenView()
    }
}
