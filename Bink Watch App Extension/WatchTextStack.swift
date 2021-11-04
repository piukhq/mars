//
//  WatchTextStack.swift
//  binkapp
//
//  Created by Sean Williams on 04/11/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import SwiftUI

struct WatchTextStack: View {
    var title: String
    var description: String
    
    var body: some View {
        VStack {
            Text(title)
                .font(.nunitoExtraBold(18))
                .multilineTextAlignment(.center)
            Text(description)
                .font(.nunitoSans(17))
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.5)
        }
        .padding([.leading, .trailing])
    }
}


struct WatchTextStack_Previews: PreviewProvider {
    static var previews: some View {
        WatchTextStack(title: "Title", description: "Body text")
    }
}
